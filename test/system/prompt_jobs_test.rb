require "application_system_test_case"

class PromptJobsTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    @other_user = users(:user_two)
    @prompt_job = prompt_jobs(:one)
    @other_users_prompt_job = prompt_jobs(:two)
    @llm_model = llm_models(:one)
    @plan = plans(:basic)

    # Set up user's plan with access to the LLM model
    @plan.llm_models << @llm_model
    @user.update!(plan: @plan)
  end

  test "should redirect to sign in when not authenticated" do
    visit prompt_jobs_url
    assert_current_path new_user_session_path
  end

  test "visiting the index shows only user's prompt jobs" do
    sign_in @user
    visit prompt_jobs_url

    assert_selector "h1", text: "Prompt Jobs"
    assert_text @prompt_job.prompt
    assert_no_text @other_users_prompt_job.prompt
  end

  test "should create prompt job" do
    sign_in @user
    visit prompt_jobs_url
    click_on "New prompt job"

    fill_in "Prompt", with: "Test prompt for system test"
    check "llm_model_#{@llm_model.id}"
    click_on "Create Prompt job"

    assert_text "Prompt job was successfully created"
    assert_text "Test prompt for system test"
  end

  test "should destroy user's own Prompt job" do
    sign_in @user
    visit prompt_job_url(@prompt_job)

    accept_confirm do
      click_on "Delete"
    end

    assert_text "Prompt job was successfully destroyed"
  end

  test "cannot access another user's prompt job" do
    sign_in @user
    visit prompt_job_url(@other_users_prompt_job)

    assert_text "You are not authorized to access this page."
    assert_current_path root_path
  end
end
