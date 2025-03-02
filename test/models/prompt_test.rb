require "test_helper"

class PromptTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @subscription = FactoryBot.create(:subscription, priority: 2)
    @subscription_history = FactoryBot.create(:subscription_history, user: @user, subscription: @subscription)
    @llm1 = FactoryBot.create(:llm, name: "LLM 1", active: true)
    @llm2 = FactoryBot.create(:llm, name: "LLM 2", active: true)

    # Associate LLMs with the subscription
    FactoryBot.create(:subscription_llm, subscription: @subscription, llm: @llm1)
    FactoryBot.create(:subscription_llm, subscription: @subscription, llm: @llm2)
  end

  test "should be valid" do
    prompt = FactoryBot.build(:prompt, user: @user)
    assert prompt.valid?
  end

  test "should require content" do
    prompt = FactoryBot.build(:prompt, user: @user, content: nil)
    assert_not prompt.valid?
  end

  test "should require status" do
    prompt = FactoryBot.build(:prompt, user: @user, status: nil)
    assert_not prompt.valid?
  end

  test "should validate status inclusion" do
    prompt = FactoryBot.build(:prompt, user: @user, status: "invalid")
    assert_not prompt.valid?

    prompt.status = "waiting"
    assert prompt.valid?

    prompt.status = "in_queue"
    assert prompt.valid?

    prompt.status = "processing"
    assert prompt.valid?

    prompt.status = "completed"
    assert prompt.valid?

    prompt.status = "failed"
    assert prompt.valid?
  end

  test "should create llm jobs after create" do
    prompt = FactoryBot.create(:prompt, user: @user)

    # Should have created 2 LLM jobs (one for each LLM in the subscription)
    assert_equal 2, prompt.llm_jobs.count

    # Jobs should be queued
    assert prompt.llm_jobs.all? { |job| job.status == "queued" }

    # Jobs should have the priority from the subscription
    assert prompt.llm_jobs.all? { |job| job.priority == @subscription.priority }

    # Prompt status should be updated to in_queue
    assert_equal "in_queue", prompt.status
  end

  test "should update status based on job statuses" do
    # Disable the after_create callback to avoid creating extra jobs
    Prompt.skip_callback(:create, :after, :create_llm_jobs)

    # Create a prompt with no jobs initially
    prompt = FactoryBot.create(:prompt, user: @user, status: "waiting")

    # Create jobs manually
    job1 = FactoryBot.create(:llm_job, prompt: prompt, llm: @llm1, status: "queued")
    job2 = FactoryBot.create(:llm_job, prompt: prompt, llm: @llm2, status: "queued")

    # Set prompt status to in_queue
    prompt.update!(status: "in_queue")
    assert_equal "in_queue", prompt.status

    # Test processing status
    job1.update!(status: "processing", started_at: Time.current)
    prompt.update_status
    prompt.reload
    assert_equal "processing", prompt.status

    # Test still processing when one job is completed
    job1.update!(status: "completed", response: "Test response", response_time_ms: 1000, completed_at: Time.current)
    prompt.update_status
    prompt.reload
    assert_equal "in_queue", prompt.status

    # Test completed status
    job2.update!(status: "processing", started_at: Time.current)
    prompt.update_status
    prompt.reload
    assert_equal "processing", prompt.status

    job2.update!(status: "completed", response: "Test response 2", response_time_ms: 2000, completed_at: Time.current)
    prompt.update_status
    prompt.reload
    assert_equal "completed", prompt.status

    # Test failed scenario
    prompt2 = FactoryBot.create(:prompt, user: @user, status: "waiting")
    job3 = FactoryBot.create(:llm_job, prompt: prompt2, llm: @llm1, status: "queued")
    job4 = FactoryBot.create(:llm_job, prompt: prompt2, llm: @llm2, status: "queued")

    prompt2.update!(status: "in_queue")

    job3.update!(status: "processing", started_at: Time.current)
    prompt2.update_status
    prompt2.reload
    assert_equal "processing", prompt2.status

    job3.update!(status: "failed", error_message: "Test error", completed_at: Time.current)
    prompt2.update_status
    prompt2.reload
    assert_equal "in_queue", prompt2.status

    job4.update!(status: "processing", started_at: Time.current)
    prompt2.update_status
    prompt2.reload
    assert_equal "processing", prompt2.status

    job4.update!(status: "failed", error_message: "Test error", completed_at: Time.current)
    prompt2.update_status
    prompt2.reload
    assert_equal "failed", prompt2.status

    # Re-enable the callback for other tests
    Prompt.set_callback(:create, :after, :create_llm_jobs)
  end
end
