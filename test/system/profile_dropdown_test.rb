require "application_system_test_case"

class ProfileDropdownTest < ApplicationSystemTestCase
  test "clicking profile button toggles dropdown menu" do
    visit root_path
    
    # Initially dropdown should be hidden
    assert_selector "#user-menu-button"
    assert_no_selector "#user-menu-item-0"
    assert_no_selector "#user-menu-item-1"
    
    # Click the button to open dropdown
    find("#user-menu-button").click
    
    # Dropdown items should now be visible
    assert_selector "#user-menu-item-0", text: "Your profile"
    assert_selector "#user-menu-item-1", text: "Sign out"
    
    # Click away (on the body) to close dropdown
    find("body").click
    
    # Dropdown should be hidden again
    assert_no_selector "#user-menu-item-0"
    assert_no_selector "#user-menu-item-1"
  end

  test "clicking menu items closes dropdown" do
    visit root_path
    
    # Open dropdown
    find("#user-menu-button").click
    assert_selector "#user-menu-item-0"
    
    # Click profile link
    find("#user-menu-item-0").click
    
    # Dropdown should close
    assert_no_selector "#user-menu-item-0"
    assert_no_selector "#user-menu-item-1"
  end
end 