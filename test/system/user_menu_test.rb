require "application_system_test_case"

class UserMenuTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test "can toggle user menu on mobile" do
    # Set mobile viewport (iPhone X)
    page.driver.browser.manage.window.resize_to(375, 812)

    visit root_path

    # Menu should be hidden by default
    assert_selector 'div[data-dropdown-target="menu"]', visible: false

    # Verify Gravatar is present
    gravatar_hash = Digest::MD5.hexdigest(@user.email.strip.downcase)
    assert_selector "img[src*='#{gravatar_hash}']"

    # Click user menu button
    find("#user-menu-button").click

    # Menu should be visible
    assert_selector 'div[data-dropdown-target="menu"]', visible: true

    # Click again to close
    find("#user-menu-button").click

    # Menu should be hidden again
    assert_selector 'div[data-dropdown-target="menu"]', visible: false
  end

  test "can toggle user menu on desktop" do
    # Set desktop viewport
    page.driver.browser.manage.window.resize_to(1200, 800)

    visit root_path

    # Menu should be hidden by default
    assert_selector 'div[data-dropdown-target="menu"]', visible: false

    # Verify Gravatar is present
    gravatar_hash = Digest::MD5.hexdigest(@user.email.strip.downcase)
    assert_selector "img[src*='#{gravatar_hash}']"

    # Click user menu button (with user email visible)
    find("#user-menu-button", text: "user1@example.com").click

    # Menu should be visible with specific menu items
    assert_selector 'div[data-dropdown-target="menu"]', visible: true
    within('div[data-dropdown-target="menu"]') do
      assert_text "Your profile"
      assert_text "Sign out"
    end

    # Click again to close
    find("#user-menu-button").click

    # Menu should be hidden again
    assert_selector 'div[data-dropdown-target="menu"]', visible: false
  end
end
