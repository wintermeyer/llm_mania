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

    # Mock the call_llm_api method for all tests
    ProcessLlmJob.any_instance.stubs(:call_llm_api).returns("Test LLM response")

    # Mock QueueManagerJob to not actually perform
    @queue_manager_called = false
    QueueManagerJob.stubs(:perform_later).with do
      @queue_manager_called = true
    end
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

    # Verify QueueManagerJob was called
    assert @queue_manager_called, "QueueManagerJob.perform_later should have been called"
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
    # For this test, make the call_llm_api method raise an error
    ProcessLlmJob.any_instance.stubs(:call_llm_api).raises(StandardError.new("Test error"))

    # Reset the flag
    @queue_manager_called = false

    # Process the job (should rescue and not raise the error in perform)
    ProcessLlmJob.perform_now(@llm_job.id)

    # Reload the job
    @llm_job.reload

    # Job should be failed
    assert_equal "failed", @llm_job.status

    # Should have an error message
    assert_equal "Test error", @llm_job.error_message

    # Should have timestamps
    assert_not_nil @llm_job.started_at
    assert_not_nil @llm_job.completed_at

    # Verify QueueManagerJob was called
    assert @queue_manager_called, "QueueManagerJob.perform_later should have been called"
  end

  test "should not process a job that is not queued" do
    # Mark the job as processing
    @llm_job.update!(status: "processing")

    # Reset the flag
    @queue_manager_called = false

    # Process the job
    ProcessLlmJob.perform_now(@llm_job.id)

    # Reload the job
    @llm_job.reload

    # Job should still be processing
    assert_equal "processing", @llm_job.status

    # Should not have a response
    assert_nil @llm_job.response

    # QueueManagerJob should not have been called
    assert_not @queue_manager_called, "QueueManagerJob.perform_later should not have been called"
  end
end
