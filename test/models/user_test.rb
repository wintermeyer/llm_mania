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

  test "new user should be assigned the cheapest active subscription" do
    # Create subscriptions with different prices
    expensive_subscription = create(:subscription, price_cents: 1000, active: true)
    mid_subscription = create(:subscription, price_cents: 500, active: true)
    cheap_subscription = create(:subscription, price_cents: 0, active: true)
    inactive_subscription = create(:subscription, price_cents: 0, active: false)

    # Create a new user
    user = create(:user)

    # Check if the user has a subscription history
    assert_equal 1, user.subscription_histories.count

    # Check if the assigned subscription is the cheapest one
    user_subscription = user.subscription_histories.first.subscription
    assert_equal cheap_subscription, user_subscription

    # Check if the subscription dates are correct
    subscription_history = user.subscription_histories.first
    assert subscription_history.start_date <= Time.current
    assert subscription_history.end_date >= Time.current
  end

  test "new user should be assigned the oldest subscription when multiple have the same price" do
    # Create subscriptions with the same price but different creation times
    sleep(1) # Ensure different created_at times
    newer_subscription = create(:subscription, price_cents: 0, active: true)
    sleep(1)
    newest_subscription = create(:subscription, price_cents: 0, active: true)

    # Create an older subscription by manipulating the created_at
    oldest_subscription = create(:subscription, price_cents: 0, active: true)
    oldest_subscription.update_column(:created_at, 1.day.ago)

    # Create a new user
    user = create(:user)

    # Check if the assigned subscription is the oldest one
    user_subscription = user.subscription_histories.first.subscription
    assert_equal oldest_subscription, user_subscription
  end

  test "new user should have nil subscription when no subscriptions exist" do
    # Ensure no subscriptions exist
    Subscription.destroy_all

    # Create a new user
    user = create(:user)

    # Check if the user has no subscription history
    assert_equal 0, user.subscription_histories.count
  end

  test "should not override existing subscription when user is created with one" do
    # Create subscriptions
    expensive_subscription = create(:subscription, price_cents: 1000, active: true)
    cheap_subscription = create(:subscription, price_cents: 0, active: true)

    # Create a user and manually assign a subscription (before the callback runs)
    user = build(:user)

    # Create a subscription history manually
    subscription_history = build(:subscription_history,
      user: user,
      subscription: expensive_subscription,
      start_date: Time.current,
      end_date: 6.months.from_now
    )

    # Save the user with the subscription history
    user.subscription_histories << subscription_history
    user.save!

    # Check if the user still has the manually assigned subscription
    assert_equal 1, user.subscription_histories.count
    assert_equal expensive_subscription, user.subscription_histories.first.subscription
    assert_equal 6.months.from_now.to_date, user.subscription_histories.first.end_date.to_date
  end
end
