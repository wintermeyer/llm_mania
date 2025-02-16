require "application_system_test_case"

class UserMenuTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, first_name: "Tom", last_name: "Cook", gender: "male", email: "tom.cook@example.com", password: "password123")
    login_as(@user, scope: :user)
  end

  test "can toggle user menu on mobile" do
    # Set mobile viewport (iPhone X)
    page.driver.browser.manage.window.resize_to(375, 812)

    visit root_path

    # Menu should be hidden by default
    assert_selector 'div[data-dropdown-target="menu"]', visible: false

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

    # Click user menu button (with user name visible)
    find("#user-menu-button", text: "Tom Cook").click

    # Menu should be visible with specific menu items
    assert_selector 'div[data-dropdown-target="menu"]', visible: true
    within('div[data-dropdown-target="menu"]') do
      assert_text I18n.t("devise.shared.navigation.your_profile")
      assert_text I18n.t("devise.shared.navigation.sign_out")
    end

    # Click again to close
    find("#user-menu-button").click

    # Menu should be hidden again
    assert_selector 'div[data-dropdown-target="menu"]', visible: false
  end

  test "menu closes when clicking outside" do
    # Set desktop viewport
    page.driver.browser.manage.window.resize_to(1200, 800)

    visit root_path

    # Open the menu
    find("#user-menu-button", text: "Tom Cook").click

    # Menu should be visible
    assert_selector 'div[data-dropdown-target="menu"]', visible: true

    # Click outside the menu (on the main content area)
    find("main.py-10").click

    # Menu should be hidden
    assert_selector 'div[data-dropdown-target="menu"]', visible: false
  end

  test "shows sign in and register links when not logged in" do
    logout(:user)
    visit root_path

    assert_link I18n.t("devise.shared.navigation.sign_in"), href: new_user_session_path
    assert_link I18n.t("devise.shared.navigation.register"), href: new_user_registration_path
    assert_no_selector "#user-menu-button"
  end
end
