require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "can toggle mobile navigation menu" do
    # Set a mobile device viewport
    page.driver.browser.manage.window.resize_to(375, 812) # iPhone X dimensions

    visit root_path

    # Menu should be hidden by default
    menu = find("#mobile-navigation", visible: false)
    assert_equal "display: none;", menu["style"]
    assert_not_predicate menu, :visible?

    # Click hamburger menu
    find('button[aria-controls="mobile-navigation"]', text: "Open sidebar").click

    # Menu should be visible
    menu = find("#mobile-navigation")
    assert_equal "display: block;", menu["style"]
    assert_predicate menu, :visible?

    # Verify menu content
    within("#mobile-navigation") do
      assert_text "Dashboard"
      assert_text "Team"
    end

    # Click close button
    find('button[aria-controls="mobile-navigation"]', text: "Close sidebar").click

    # Menu should be hidden again
    menu = find("#mobile-navigation", visible: false)
    assert_equal "display: none;", menu["style"]
    assert_not_predicate menu, :visible?
  end

  test "desktop shows static sidebar" do
    # Set a desktop viewport
    page.driver.browser.manage.window.resize_to(1200, 800)

    visit root_path

    # Mobile menu should not be visible
    assert_no_selector("#mobile-navigation", visible: true)

    # Desktop sidebar should be visible
    within("div.lg\\:fixed") do
      assert_text "Dashboard"
      assert_text "Team"
    end

    # Hamburger menu button should not be visible
    assert_no_selector('button[aria-controls="mobile-navigation"]', visible: true)
  end
end
