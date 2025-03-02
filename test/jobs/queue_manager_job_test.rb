require "test_helper"

class QueueManagerJobTest < ActiveJob::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @subscription = FactoryBot.create(:subscription, priority: 2)
    @subscription_history = FactoryBot.create(:subscription_history, user: @user, subscription: @subscription)
    @llm = FactoryBot.create(:llm, active: true)
    @prompt = FactoryBot.create(:prompt, user: @user)

    # Create a system config for max concurrent jobs
    SystemConfig.set("max_concurrent_jobs", "2")

    # Clear any existing jobs in GoodJob
    GoodJob::Job.delete_all
  end

  test "should process queued jobs up to max concurrent limit" do
    # Create 3 jobs
    job1 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job2 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job3 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")

    # Run the queue manager
    QueueManagerJob.perform_now

    # Should have enqueued 2 ProcessLlmJob jobs (max concurrent is 2)
    assert_equal 2, GoodJob::Job.where(job_class: "ProcessLlmJob").count

    # Process the enqueued jobs
    GoodJob::Job.all.each do |job|
      job_data = JSON.parse(job.serialized_params)
      job_class = job_data["job_class"]
      job_args = job_data["arguments"]

      if job_class == "ProcessLlmJob"
        ProcessLlmJob.perform_now(*job_args)
      end
    end

    # Reload the jobs
    job1.reload
    job2.reload
    job3.reload

    # First two jobs should be processing
    assert_equal "processing", job1.status
    assert_equal "processing", job2.status

    # Third job should still be queued
    assert_equal "queued", job3.status

    # Complete one job
    job1.complete!("Test response", 1000)

    # Clear the job queue
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear

    # Run the queue manager again
    QueueManagerJob.perform_now

    # Should have enqueued 1 more ProcessLlmJob job
    assert_enqueued_jobs 1, only: ProcessLlmJob

    # Process the enqueued job
    perform_enqueued_jobs

    # Reload the third job
    job3.reload

    # Third job should now be processing
    assert_equal "processing", job3.status
  end

  test "should respect job priority and position" do
    # Create 3 jobs with different priorities
    job1 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 3, status: "queued")
    job2 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 1, status: "queued")
    job3 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")

    # Run the queue manager
    QueueManagerJob.perform_now

    # Process the enqueued jobs
    GoodJob::Job.all.each do |job|
      job_data = JSON.parse(job.serialized_params)
      job_class = job_data["job_class"]
      job_args = job_data["arguments"]

      if job_class == "ProcessLlmJob"
        ProcessLlmJob.perform_now(*job_args)
      end
    end

    # Reload the jobs
    job1.reload
    job2.reload
    job3.reload

    # Highest priority job should be processing
    assert_equal "processing", job1.status
    assert_equal "processing", job3.status

    # Lowest priority job should still be queued
    assert_equal "queued", job2.status
  end
end
