require "test_helper"

class PromptJobTest < ActiveSupport::TestCase
  def setup
    @prompt_job = prompt_jobs(:one)
    @user = users(:user_one)
    @plan = plans(:basic)
    @llm_model = llm_models(:one)
  end

  test "should be valid with valid attributes" do
    prompt_job = PromptJob.new(
      prompt: "Write a function to calculate prime numbers up to n",
      user: @user
    )
    assert prompt_job.valid?
  end

  test "should not be valid without prompt" do
    prompt_job = PromptJob.new(user: @user)
    assert_not prompt_job.valid?
    assert_includes prompt_job.errors[:prompt], "can't be blank"
  end

  test "should not be valid with short prompt" do
    prompt_job = PromptJob.new(
      prompt: "Short",
      user: @user
    )
    assert_not prompt_job.valid?
    assert_includes prompt_job.errors[:prompt], "is too short (minimum is 10 characters)"
  end

  test "should have access to plan's LLM models" do
    @plan.llm_models << @llm_model
    @user.update!(plan: @plan)
    prompt_job = PromptJob.create!(prompt: "Write a function to calculate prime numbers up to n", user: @user)

    assert_includes prompt_job.available_llm_models, @llm_model
  end

  test "should have access to plan through user" do
    @user.update!(plan: @plan)
    prompt_job = PromptJob.create!(prompt: "Write a function to calculate prime numbers up to n", user: @user)

    assert_equal @plan, prompt_job.plan
  end
end
