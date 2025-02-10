require "application_system_test_case"

class PlansTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
    @regular_user = users(:user_one)
    @plan = plans(:basic)
  end

  test "visiting the index as anonymous user shows only active plans and hides admin controls" do
    visit plans_url
    assert_selector "h1", text: "Plans"

    # Should show active plans
    assert_text plans(:basic).name
    assert_text plans(:pro).name

    # Should not show inactive plans
    assert_no_text plans(:enterprise).name

    # Should not show admin controls
    assert_no_selector "a", text: "Add plan"
    assert_no_selector "a", text: "Edit"
    assert_no_selector "button", text: "Delete"
  end

  test "visiting the index displays prices in EUR format" do
    visit plans_url
    # Verify prices are displayed with EUR symbol and correct format
    assert_text "€8.99" # Basic Plan
    assert_text "€24.99" # Pro Plan
  end

  test "visiting the index as admin shows all plans and new button" do
    sign_in @admin
    visit plans_url
    assert_selector "h1", text: "Plans"
    assert_selector "a", text: "Add plan"
    assert_text plans(:basic).name
    assert_text plans(:pro).name
    assert_text plans(:enterprise).name
  end

  test "visiting the index as regular user hides new button and inactive plans" do
    sign_in @regular_user
    visit plans_url
    assert_selector "h1", text: "Plans"
    assert_no_selector "a", text: "Add plan"
    assert_text plans(:basic).name
    assert_text plans(:pro).name
    assert_no_text plans(:enterprise).name
  end

  test "admin can access new plan page directly" do
    sign_in @admin
    visit new_plan_url
    assert_selector "h1", text: "New Plan"
    assert_selector "form" do
      assert_selector "input[name='plan[name]']"
      assert_selector "input[name='plan[price]']"
      assert_selector "input[name='plan[is_active]']"
    end
  end

  test "creating a new plan as admin" do
    sign_in @admin
    visit plans_url
    click_on "Add plan"

    fill_in "Name", with: "Premium Plan"
    fill_in "Description", with: "This is a premium plan with advanced features"
    fill_in "Price", with: "49.99"
    check "Active"
    click_on "Create plan"

    assert_text "Plan was successfully created"
    assert_text "Premium Plan"
    assert_text "€49.99"
  end

  test "cannot create plan as regular user" do
    sign_in @regular_user
    visit new_plan_url

    assert_text "You are not authorized to perform this action"
    assert_current_path root_path
  end

  test "updating a plan as admin" do
    sign_in @admin
    visit plan_url(@plan)
    click_on "Edit", match: :first

    fill_in "Name", with: "Updated Plan"
    fill_in "Description", with: "This is an updated plan description"
    fill_in "Price", with: "29.99"
    click_on "Update plan"

    assert_text "Plan was successfully updated"
    assert_text "Updated Plan"
    assert_text "€29.99"
  end

  test "destroying a plan as admin" do
    sign_in @admin
    visit plan_url(@plan)
    accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Plan was successfully destroyed"
  end

  test "regular user cannot access new plan page" do
    sign_in @regular_user
    visit new_plan_url

    assert_text "You are not authorized to perform this action"
    assert_current_path root_path
  end

  test "regular user cannot access edit plan page" do
    sign_in @regular_user
    visit edit_plan_url(@plan)

    assert_text "You are not authorized to perform this action"
    assert_current_path root_path
  end
end
