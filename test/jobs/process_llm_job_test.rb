require "test_helper"

class ProcessLlmJobTest < ActiveJob::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @subscription = FactoryBot.create(:subscription, priority: 2)
    @subscription_history = FactoryBot.create(:subscription_history, user: @user, subscription: @subscription)
    @llm = FactoryBot.create(:llm, active: true)
    @prompt = FactoryBot.create(:prompt, user: @user)
    @llm_job = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")

    # Clear any existing jobs in GoodJob
    GoodJob::Job.delete_all
  end

  test "should process a job" do
    # Process the job
    ProcessLlmJob.perform_now(@llm_job.id)

    # Reload the job
    @llm_job.reload

    # Job should be completed
    assert_equal "completed", @llm_job.status

    # Should have a response
    assert_not_nil @llm_job.response

    # Should have a response time
    assert_not_nil @llm_job.response_time_ms

    # Should have timestamps
    assert_not_nil @llm_job.started_at
    assert_not_nil @llm_job.completed_at

    # Should have enqueued a QueueManagerJob
    assert_enqueued_jobs 1, only: QueueManagerJob
  end

  test "should update prompt status" do
    # Process the job
    ProcessLlmJob.perform_now(@llm_job.id)

    # Reload the prompt
    @prompt.reload

    # Prompt should be completed
    assert_equal "completed", @prompt.status
  end

  test "should handle errors" do
    # Temporarily redefine the call_llm_api method for this test
    ProcessLlmJob.class_eval do
      def call_llm_api(llm_job)
        raise StandardError, "Test error"
      end
    end

    # Process the job (should raise an error)
    assert_raises StandardError do
      ProcessLlmJob.perform_now(@llm_job.id)
    end

    # Reload the job
    @llm_job.reload

    # Job should be failed
    assert_equal "failed", @llm_job.status

    # Should have an error message
    assert_equal "Test error", @llm_job.error_message

    # Should have timestamps
    assert_not_nil @llm_job.started_at
    assert_not_nil @llm_job.completed_at

    # Should have enqueued a QueueManagerJob
    assert_enqueued_jobs 1, only: QueueManagerJob
  ensure
    # Restore the original method after the test
    ProcessLlmJob.class_eval do
      remove_method :call_llm_api
    end
    load Rails.root.join('app/jobs/process_llm_job.rb')
  end

  test "should not process a job that is not queued" do
    # Mark the job as processing
    @llm_job.update!(status: "processing")

    # Get current job count for QueueManagerJob
    initial_job_count = GoodJob::Job.where("serialized_params LIKE ?", "%QueueManagerJob%").count

    # Process the job
    ProcessLlmJob.perform_now(@llm_job.id)

    # Reload the job
    @llm_job.reload

    # Job should still be processing
    assert_equal "processing", @llm_job.status

    # Should not have a response
    assert_nil @llm_job.response

    # Should not have enqueued a QueueManagerJob
    final_job_count = GoodJob::Job.where("serialized_params LIKE ?", "%QueueManagerJob%").count
    assert_equal initial_job_count, final_job_count, "No QueueManagerJob should have been enqueued"
  end
end
