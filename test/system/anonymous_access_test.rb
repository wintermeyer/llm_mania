require "application_system_test_case"

class AnonymousAccessTest < ApplicationSystemTestCase
  test "visiting the root page as anonymous user" do
    visit root_path

    # Verify we're on the home page
    assert_selector "h1", text: "LLM Mania"

    # Verify authentication links are present
    assert_selector "a", text: "Sign in"
    assert_selector "a", text: "Sign up"

    # Verify we can't see authenticated user elements
    assert_no_selector "[data-testid='profile-menu']"
  end
end
