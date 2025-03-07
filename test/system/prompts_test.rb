require "application_system_test_case"

class PromptsTest < ApplicationSystemTestCase
  setup do
    # Set up Devise mapping explicitly for this test
    Devise.mappings[:user] = Devise.mappings[:user] || Devise::Mapping.new(:user, {})

    # Create user with subscription and LLMs
    @user = create(:user, confirmed_at: Time.current)
    @subscription = create(:subscription, max_prompt_length: 1500, private_prompts_allowed: true)
    @llm1 = create(:llm, name: "Model 1", size: 7, creator: "OpenAI")
    @llm2 = create(:llm, name: "Model 2", size: 13, creator: "Anthropic")
    create(:subscription_llm, subscription: @subscription, llm: @llm1)
    create(:subscription_llm, subscription: @subscription, llm: @llm2)
    create(:subscription_history, user: @user, subscription: @subscription)

    sign_in @user
  end

  test "visiting the new prompt page" do
    visit new_prompt_path

    # Verify we're on the new prompt page
    assert_selector "h1", text: "Create a New Prompt"

    # Verify form elements are present
    assert_selector "label", text: "Prompt Content"
    assert_selector "textarea#prompt_content"
    assert_selector "h2", text: "Select Language Models"
    assert_selector "div", text: "Model 1"
    assert_selector "div", text: "Model 2"
    assert_selector "label", text: "Make this prompt private"
    assert_selector "input#prompt_private[type='checkbox']"
    assert_selector "input[type='submit'][value='Create Prompt']"
  end

  test "creating a new prompt with selected LLMs" do
    visit new_prompt_path

    # Fill in the form with valid content
    fill_in "prompt_content", with: "This is a test prompt with sufficient content"
    check "prompt_private"

    # Submit the form
    click_button "Create Prompt"

    # Verify we're redirected to the root path with a success message
    assert_current_path root_path
    assert_text "Prompt was successfully created."

    # Verify the prompt was created with the correct attributes
    prompt = Prompt.last
    assert_equal "This is a test prompt with sufficient content", prompt.content
    assert prompt.private
  end

  test "creating a new prompt with only one LLM selected" do
    visit new_prompt_path

    # Fill in the form with valid content
    fill_in "prompt_content", with: "This is a test prompt with sufficient content"

    # Uncheck one of the LLMs - now we can use a regular uncheck since our checkboxes are visible
    uncheck "llm_#{@llm2.id}"

    # Submit the form
    click_button "Create Prompt"

    # Verify we're redirected to the root path with a success message
    assert_current_path root_path
    assert_text "Prompt was successfully created."

    # Verify the prompt was created with the correct attributes
    prompt = Prompt.last
    assert_equal "This is a test prompt with sufficient content", prompt.content
  end

  test "attempting to create an invalid prompt" do
    visit new_prompt_path

    # Submit the form without filling in the content
    click_button "Create Prompt"

    # Verify we're still on the new prompt page with an error message
    assert_text "There were problems with your submission:"
    assert_text "Content can't be blank"
  end

  test "canceling prompt creation" do
    skip "Cancel button has been removed from the form"
    visit new_prompt_path

    # Click the cancel button
    click_on "Cancel"

    # Verify we're redirected to the root path
    assert_current_path root_path
  end
end
