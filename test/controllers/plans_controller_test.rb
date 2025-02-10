require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plan = plans(:basic)
    @admin = users(:admin)
    @regular_user = users(:user_one)
  end

  test "should get index" do
    get plans_url
    assert_response :success
  end

  test "should return 200 status code for plans index" do
    get plans_url
    assert_equal 200, response.status
  end

  test "should get new when admin" do
    sign_in @admin
    get new_plan_url
    assert_response :success
  end

  test "should not get new when regular user" do
    sign_in @regular_user
    get new_plan_url
    assert_redirected_to root_url
  end

  test "should create plan when admin" do
    sign_in @admin
    assert_difference("Plan.count") do
      post plans_url, params: { plan: {
        name: "Test Plan",
        price: 19.99,
        is_active: true,
        description: "A test plan with sufficient description length.",
        is_default: false
      } }
    end

    assert_redirected_to plan_url(Plan.last)
  end

  test "should not create plan when regular user" do
    sign_in @regular_user
    assert_no_difference("Plan.count") do
      post plans_url, params: { plan: {
        name: "Premium Plan",
        description: "This is a premium plan with advanced features",
        price: "49.99",
        is_active: true
      } }
    end

    assert_redirected_to root_url
  end

  test "should show plan" do
    get plan_url(@plan)
    assert_response :success
  end

  test "should get edit when admin" do
    sign_in @admin
    get edit_plan_url(@plan)
    assert_response :success
  end

  test "should not get edit when regular user" do
    sign_in @regular_user
    get edit_plan_url(@plan)
    assert_redirected_to root_url
  end

  test "should update plan when admin" do
    sign_in @admin
    patch plan_url(@plan), params: { plan: {
      name: @plan.name,
      price: 29.99,
      is_active: @plan.is_active,
      description: @plan.description,
      is_default: @plan.is_default
    } }
    assert_redirected_to plan_url(@plan)
  end

  test "should not update plan when regular user" do
    sign_in @regular_user
    original_name = @plan.name
    patch plan_url(@plan), params: { plan: {
      name: "Updated Plan",
      description: "This is an updated plan description",
      price: "29.99",
      is_active: false
    } }
    assert_redirected_to root_url
    @plan.reload
    assert_equal original_name, @plan.name
  end

  test "should destroy plan when admin and no users are using it" do
    sign_in @admin
    plan_without_users = plans(:enterprise) # Using enterprise plan as it's inactive and shouldn't have users

    assert_difference("Plan.count", -1) do
      delete plan_url(plan_without_users)
    end

    assert_redirected_to plans_url
  end

  test "should not destroy plan when it has users" do
    sign_in @admin
    plan_with_users = plans(:basic) # Basic plan has associated users

    assert_no_difference("Plan.count") do
      delete plan_url(plan_with_users)
    end

    assert_redirected_to plans_url
    assert_equal "Cannot delete record because dependent users exist", flash[:alert]
  end
end
