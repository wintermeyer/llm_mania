require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  setup do
    # Find or create roles for testing
    @admin_role = Role.find_or_create_by!(name: "admin") do |role|
      role.description = "Administrator role with full access"
      role.active = true
    end

    @user_role = Role.find_or_create_by!(name: "user") do |role|
      role.description = "Regular user role with standard access"
      role.active = true
    end

    # Create users
    @admin = create(:user)
    @admin.roles.delete_all  # Remove any existing roles
    @admin.roles << @admin_role
    @admin.update!(current_role: @admin_role)

    @regular_user = create(:user)
    @regular_user.roles.delete_all  # Remove any existing roles
    @regular_user.roles << @user_role
    @regular_user.update!(current_role: @user_role)

    # User with admin role but nil current_role
    @nil_current_role_admin = create(:user)
    @nil_current_role_admin.roles.delete_all
    @nil_current_role_admin.roles << @admin_role
    # Need to update the database directly to bypass validations and callbacks
    User.where(id: @nil_current_role_admin.id).update_all(current_role_id: nil)
    @nil_current_role_admin.reload

    # Create a prompt
    @prompt = create(:prompt, user: @regular_user)
  end

  test "admin user can manage all resources" do
    ability = Ability.new(@admin)

    assert ability.can?(:manage, @prompt)
    assert ability.can?(:manage, Llm)
    assert ability.can?(:manage, Role)
    assert ability.can?(:manage, User)
  end

  test "regular user can manage their own prompts" do
    ability = Ability.new(@regular_user)

    assert ability.can?(:manage, @prompt)
    assert ability.cannot?(:manage, Prompt.new)
    assert ability.cannot?(:manage, Role)
    assert ability.cannot?(:manage, User)
  end

  test "guest user cannot manage any resources" do
    ability = Ability.new(nil)

    assert ability.cannot?(:manage, @prompt)
    assert ability.cannot?(:manage, Llm)
    assert ability.cannot?(:manage, Role)
    assert ability.cannot?(:manage, User)
  end

  test "user with admin role but nil current_role cannot manage all resources" do
    # Verify the current_role is nil (our test is valid)
    assert_nil @nil_current_role_admin.current_role

    ability = Ability.new(@nil_current_role_admin)

    # User should only have basic permissions, not admin permissions
    assert ability.cannot?(:manage, @prompt)
    assert ability.cannot?(:manage, Llm)
    assert ability.cannot?(:manage, Role)
    assert ability.cannot?(:manage, User)

    # But they should still have basic user permissions
    assert ability.can?(:read, Prompt.new(hidden: false, private: false))
    assert ability.can?(:read, Llm.new(active: true))
    assert ability.can?(:read, Rating.new)
    assert ability.can?(:read, SubscriptionHistory.new(user_id: @nil_current_role_admin.id))
  end
end
