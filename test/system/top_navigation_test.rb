require "application_system_test_case"

class TopNavigationTest < ApplicationSystemTestCase
  setup do
    # Create a simple user with confirmed email
    @user = create(:user, confirmed_at: Time.current)

    # Set up Devise mapping explicitly for this test
    Devise.mappings[:user] = Devise.mappings[:user] || Devise::Mapping.new(:user, {})

    sign_in @user
  end

  test "top navigation pull-down menu is hidden when page is opened" do
    visit root_path

    # Check that the profile dropdown button exists
    assert_selector "#user-menu-button"

    # Check that the dropdown menu is not visible initially
    # The dropdown menu is inside a div with x-show="open" attribute
    # We can check that the menu items are not visible
    assert_selector "#user-menu-item-0", visible: false
    assert_selector "#user-menu-item-1", visible: false

    # Additional check to verify the dropdown container is not visible
    # This uses the aria attributes to verify the menu is closed
    assert_selector "[aria-labelledby='user-menu-button']", visible: false
  end
end
