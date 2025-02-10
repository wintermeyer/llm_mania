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
        name: "Premium Plan",
        description: "This is a premium plan with advanced features",
        price: "49.99",
        is_active: true
      } }
    end

    assert_redirected_to plan_url(Plan.last)
    assert_equal "Premium Plan", Plan.last.name
    assert_equal 4999, Plan.last.price_cents
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
      name: "Updated Plan",
      description: "This is an updated plan description",
      price: "29.99",
      is_active: false
    } }

    # The plan's slug will change to match the new name
    @plan.reload
    assert_redirected_to plan_url(@plan)
    assert_equal "Updated Plan", @plan.name
    assert_equal 2999, @plan.price_cents
    assert_equal false, @plan.is_active
    assert_equal "updated-plan", @plan.slug
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

  test "should destroy plan when admin" do
    sign_in @admin
    assert_difference("Plan.count", -1) do
      delete plan_url(@plan)
    end

    assert_redirected_to plans_url
  end

  test "should not destroy plan when regular user" do
    sign_in @regular_user
    assert_no_difference("Plan.count") do
      delete plan_url(@plan)
    end

    assert_redirected_to root_url
  end
end
