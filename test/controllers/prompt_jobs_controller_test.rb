require "test_helper"

class PromptJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @other_user = users(:user_two)
    @prompt_job = prompt_jobs(:one)
    @other_users_prompt_job = prompt_jobs(:two)
  end

  test "should redirect to sign in when not authenticated" do
    get prompt_jobs_url
    assert_redirected_to new_user_session_path
  end

  test "should get index of user's prompt jobs" do
    sign_in @user
    get prompt_jobs_url
    assert_response :success
    assert_includes @response.body, @prompt_job.prompt
    assert_not_includes @response.body, @other_users_prompt_job.prompt
  end

  test "should get new" do
    sign_in @user
    get new_prompt_job_url
    assert_response :success
  end

  test "should create prompt_job" do
    sign_in @user
    assert_difference("PromptJob.count") do
      post prompt_jobs_url, params: { prompt_job: { prompt: "New test prompt" } }
    end

    assert_redirected_to prompt_job_url(PromptJob.last)
    assert_equal @user.id, PromptJob.last.user_id
  end

  test "should show user's prompt_job" do
    sign_in @user
    get prompt_job_url(@prompt_job)
    assert_response :success
  end

  test "should not show other user's prompt_job" do
    sign_in @user
    get prompt_job_url(@other_users_prompt_job)
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "should destroy user's prompt_job" do
    sign_in @user
    assert_difference("PromptJob.count", -1) do
      delete prompt_job_url(@prompt_job)
    end

    assert_redirected_to prompt_jobs_url
  end

  test "should not destroy other user's prompt_job" do
    sign_in @user
    assert_no_difference("PromptJob.count") do
      delete prompt_job_url(@other_users_prompt_job)
    end

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end
end
