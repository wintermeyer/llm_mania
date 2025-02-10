require "test_helper"

class PlanTest < ActiveSupport::TestCase
  def setup
    @plan = plans(:basic)
  end

  test "should be valid with default attributes" do
    assert @plan.valid?
  end

  test "should allow setting is_default to true when no other default exists" do
    assert_not @plan.is_default?
    @plan.is_default = true
    assert @plan.valid?
  end

  test "should not allow multiple default plans" do
    # First plan becomes default
    @plan.update!(is_default: true)

    # Try to set another plan as default
    other_plan = plans(:pro)
    other_plan.is_default = true
    assert_not other_plan.valid?
    assert_includes other_plan.errors[:is_default], "can only be set for one plan"
  end

  test "should allow changing which plan is default" do
    # First plan becomes default
    @plan.update!(is_default: true)

    # Change default to another plan
    other_plan = plans(:pro)
    @plan.update!(is_default: false)
    assert other_plan.update(is_default: true)
  end

  test "default scope returns the default plan" do
    @plan.update!(is_default: true)
    assert_equal @plan, Plan.default
  end

  test "default scope returns nil when no default plan exists" do
    Plan.update_all(is_default: false)
    assert_nil Plan.default
  end

  # test "the truth" do
  #   assert true
  # end
end
