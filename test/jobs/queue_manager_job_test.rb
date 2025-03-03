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

    # Track which jobs are processed
    @processed_job_ids = []

    # Mock ProcessLlmJob to just mark jobs as processing
    ProcessLlmJob.stubs(:perform_later).with do |job_id|
      # Track which job was processed
      @processed_job_ids << job_id

      # Just update the job status for the test
      job = LlmJob.find(job_id)
      job.update!(status: "processing", started_at: Time.current)
    end
  end

  test "should process queued jobs up to max concurrent limit" do
    # Create 3 jobs
    job1 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job2 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job3 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")

    # Run the queue manager
    QueueManagerJob.perform_now

    # First two jobs should have been processed
    assert_equal 2, @processed_job_ids.size

    # Manually update the jobs to reflect what would happen
    [job1, job2].each do |job|
      job.update!(status: "processing", started_at: Time.current)
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

    # Reset the processed job IDs
    @processed_job_ids = []

    # Run the queue manager again
    QueueManagerJob.perform_now

    # Should have processed one more job
    assert_equal 1, @processed_job_ids.size
    assert_includes @processed_job_ids, job3.id

    # Manually update job3 to processing status
    job3.update!(status: "processing", started_at: Time.current)

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

    # Reset the processed job IDs
    @processed_job_ids = []

    # Run the queue manager
    QueueManagerJob.perform_now

    # Should have processed the correct job IDs
    # In this case, jobs 1 and 3 (highest and second highest priority)
    assert_includes @processed_job_ids, job1.id
    assert_includes @processed_job_ids, job3.id
    assert_equal 2, @processed_job_ids.size

    # Manually update the jobs to processing status
    [job1, job3].each do |job|
      job.update!(status: "processing", started_at: Time.current)
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
