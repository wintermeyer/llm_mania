require "application_system_test_case"

class PromptJobsTest < ApplicationSystemTestCase
  setup do
    @prompt_job = prompt_jobs(:one)
  end

  test "visiting the index" do
    visit prompt_jobs_url
    assert_selector "h1", text: "Prompt jobs"
  end

  test "should create prompt job" do
    visit prompt_jobs_url
    click_on "New prompt job"

    fill_in "Prompt", with: @prompt_job.prompt
    fill_in "User", with: @prompt_job.user_id
    click_on "Create Prompt job"

    assert_text "Prompt job was successfully created"
    click_on "Back"
  end

  test "should update Prompt job" do
    visit prompt_job_url(@prompt_job)
    click_on "Edit this prompt job", match: :first

    fill_in "Prompt", with: @prompt_job.prompt
    fill_in "User", with: @prompt_job.user_id
    click_on "Update Prompt job"

    assert_text "Prompt job was successfully updated"
    click_on "Back"
  end

  test "should destroy Prompt job" do
    visit prompt_job_url(@prompt_job)
    click_on "Destroy this prompt job", match: :first

    assert_text "Prompt job was successfully destroyed"
  end
end
