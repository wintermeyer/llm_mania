require "application_system_test_case"

class MobileMenuTest < ApplicationSystemTestCase
  setup do
    # Set viewport to mobile size (iPhone SE dimensions)
    page.driver.browser.manage.window.resize_to(375, 667)
  end

  test "mobile menu is hidden by default" do
    visit root_path
    
    # The menu should be hidden initially
    assert_selector ".relative.z-50.lg\\:hidden", visible: false
    
    # But the burger menu button should be visible
    assert_selector "button", text: "Open sidebar", visible: :all
  end

  test "clicking burger menu opens mobile menu" do
    visit root_path
    
    # Click the burger menu button
    find("button", text: "Open sidebar").click
    
    # Menu should now be visible with its content
    assert_selector ".relative.z-50.lg\\:hidden", visible: true
    assert_selector "a", text: "Dashboard", visible: true
    assert_selector "a", text: "Team", visible: true
    
    # Close button should be visible
    assert_selector "button", text: "Close sidebar", visible: true
    
    # Click close button should hide menu
    find("button", text: "Close sidebar").click
    assert_selector ".relative.z-50.lg\\:hidden", visible: false
  end

  test "mobile menu can be closed using the cross button" do
    visit root_path
    
    # Open the menu first
    find("button", text: "Open sidebar").click
    assert_selector ".relative.z-50.lg\\:hidden", visible: true
    assert_selector "a", text: "Dashboard", visible: true
    
    # Find and click the close button (cross)
    find("button", text: "Close sidebar").click
    
    # Verify menu is hidden
    assert_selector ".relative.z-50.lg\\:hidden", visible: false
    assert_selector "a", text: "Dashboard", visible: false
    
    # Verify burger menu is still visible
    assert_selector "button", text: "Open sidebar", visible: :all
  end

  test "mobile menu has proper navigation items" do
    visit root_path
    find("button", text: "Open sidebar").click
    
    # Check for main navigation items
    within(".relative.z-50.lg\\:hidden") do
      assert_selector "a", text: "Dashboard"
      assert_selector "a", text: "Team"
      assert_selector "a", text: "Projects"
      assert_selector "a", text: "Calendar"
      assert_selector "a", text: "Documents"
      assert_selector "a", text: "Reports"
      
      # Check for teams section
      assert_selector "div", text: "Your teams"
      assert_selector "span", text: "Heroicons"
      assert_selector "span", text: "Tailwind Labs"
      assert_selector "span", text: "Workcation"
      
      # Check for settings
      assert_selector "a", text: "Settings"
    end
  end
end 