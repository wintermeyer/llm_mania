require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    user = build(:user)
    assert user.valid?
  end

  test "should require email" do
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    existing_user = create(:user)
    user = build(:user, email: existing_user.email)
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should require valid email format" do
    user = build(:user, email: "invalid_email")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "should require first_name" do
    user = build(:user, first_name: nil)
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "should require last_name" do
    user = build(:user, last_name: nil)
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "should require password" do
    user = build(:user, password: nil)
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should require valid gender" do
    user = build(:user, gender: "invalid")
    assert_not user.valid?
    assert_includes user.errors[:gender], "is not included in the list"
  end

  test "should require valid lang" do
    user = build(:user, lang: "invalid")
    assert_not user.valid?
    assert_includes user.errors[:lang], "is not included in the list"
  end

  test "should have many prompts" do
    user = create(:user_with_prompts)
    assert_equal 3, user.prompts.count
  end

  test "should have many roles through user_roles" do
    user = create(:user)
    # The user already has the default 'user' role assigned by the callback
    # So we'll create two more roles and expect a total of 3
    role1 = create(:role)
    role2 = create(:role)
    create(:user_role_association, user: user, role: role1)
    create(:user_role_association, user: user, role: role2)
    assert_equal 3, user.roles.count
    assert_includes user.roles, role1
    assert_includes user.roles, role2
    # Also verify the user has the default 'user' role
    assert_includes user.roles.map(&:name), "user"
  end

  test "should belong to current_role" do
    user = create(:user)
    admin_role = create(:admin_role)
    user.update(current_role: admin_role)
    assert_equal admin_role, user.current_role
  end

  test "should return current subscription" do
    user = create(:user)
    subscription = create(:subscription)
    create(:subscription_history,
      user: user,
      subscription: subscription,
      start_date: 1.day.ago,
      end_date: 1.day.from_now
    )
    assert_equal subscription, user.current_subscription.subscription
  end

  test "first user in development should get user and admin roles" do
    # Skip this test if not in development environment
    skip unless Rails.env.development?

    # Delete all existing users and roles to ensure clean state
    User.delete_all
    Role.delete_all

    # Create the first user
    user = create(:user)

    # Check that the user has both roles
    assert_equal 2, user.roles.count
    assert user.roles.exists?(name: "user")
    assert user.roles.exists?(name: "admin")

    # Check that the current role is set to user
    assert_equal "user", user.current_role.name
  end

  test "new user should get user role and set as current role" do
    # Create a user
    user = create(:user)

    # Check that the user has the user role
    assert user.roles.exists?(name: "user")

    # Check that the current role is set to user
    assert_equal "user", user.current_role.name
  end
end
