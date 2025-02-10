require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
    @plan = plans(:basic)
  end

  test "should be valid with all required attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password123"
    )
    assert user.valid?
  end

  test "should be valid with a plan" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      plan: @plan
    )
    assert user.valid?
  end

  test "should be valid without a plan" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      plan: nil
    )
    assert user.valid?
  end

  test "should not allow non-existent plan_id" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      User.create!(
        email: "test@example.com",
        password: "password123",
        plan_id: 99999
      )
    end
  end

  test "can belong to a plan" do
    assert_respond_to @user, :plan
    assert_instance_of Plan, @user.plan
  end

  test "can have the correct plan" do
    assert_equal plans(:basic), @user.plan
  end

  test "should assign default plan when creating user without plan_id" do
    default_plan = plans(:basic)
    default_plan.update!(is_default: true)

    user = User.new(
      email: "newuser@example.com",
      password: "password123"
    )
    user.skip_confirmation!
    user.save!

    assert_equal default_plan, user.reload.plan
  end

  test "should save specified plan_id when creating user" do
    custom_plan = plans(:pro)
    user = User.new(
      email: "newuser@example.com",
      password: "password123",
      plan_id: custom_plan.id
    )
    user.skip_confirmation!
    user.save!

    assert_equal custom_plan, user.reload.plan
  end
end
