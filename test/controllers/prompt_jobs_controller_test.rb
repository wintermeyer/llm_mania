require "test_helper"

class PromptJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @prompt_job = prompt_jobs(:one)
  end

  test "should get index" do
    get prompt_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_prompt_job_url
    assert_response :success
  end

  test "should create prompt_job" do
    assert_difference("PromptJob.count") do
      post prompt_jobs_url, params: { prompt_job: { prompt: @prompt_job.prompt, user_id: @prompt_job.user_id } }
    end

    assert_redirected_to prompt_job_url(PromptJob.last)
  end

  test "should show prompt_job" do
    get prompt_job_url(@prompt_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_prompt_job_url(@prompt_job)
    assert_response :success
  end

  test "should update prompt_job" do
    patch prompt_job_url(@prompt_job), params: { prompt_job: { prompt: @prompt_job.prompt, user_id: @prompt_job.user_id } }
    assert_redirected_to prompt_job_url(@prompt_job)
  end

  test "should destroy prompt_job" do
    assert_difference("PromptJob.count", -1) do
      delete prompt_job_url(@prompt_job)
    end

    assert_redirected_to prompt_jobs_url
  end
end
