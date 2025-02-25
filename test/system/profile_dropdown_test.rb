require "application_system_test_case"

class ProfileDropdownTest < ApplicationSystemTestCase
  setup do
    # Create a simple user with confirmed email
    @user = create(:user, confirmed_at: Time.current)
    sign_in @user
  end

  test "clicking profile button toggles dropdown menu" do
    visit root_path

    # Initially dropdown should be hidden
    assert_selector "#user-menu-button"
    # Check that dropdown items are not visible
    assert_selector "#user-menu-item-0", visible: false
    assert_selector "#user-menu-item-1", visible: false

    # Click the button to open dropdown
    find("#user-menu-button").click

    # Dropdown items should now be visible
    assert_selector "#user-menu-item-0", text: "Your profile", visible: true
    assert_selector "#user-menu-item-1", text: "Sign out", visible: true

    # Click away (on the body) to close dropdown
    find("body").click

    # Dropdown should be hidden again
    assert_selector "#user-menu-item-0", visible: false
    assert_selector "#user-menu-item-1", visible: false
  end

  test "clicking menu items closes dropdown" do
    visit root_path

    # Open dropdown
    find("#user-menu-button").click
    assert_selector "#user-menu-item-0", visible: true

    # Click profile link
    find("#user-menu-item-0").click

    # Dropdown should close
    assert_selector "#user-menu-item-0", visible: false
  end
end
