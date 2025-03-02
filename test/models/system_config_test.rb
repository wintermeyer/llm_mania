require "test_helper"

class SystemConfigTest < ActiveSupport::TestCase
  test "should be valid" do
    config = SystemConfig.new(key: "test_key", value: "test_value")
    assert config.valid?
  end

  test "should require key" do
    config = SystemConfig.new(value: "test_value")
    assert_not config.valid?
  end

  test "should require value" do
    config = SystemConfig.new(key: "test_key")
    assert_not config.valid?
  end

  test "should enforce unique keys" do
    SystemConfig.create!(key: "test_key", value: "test_value")

    config = SystemConfig.new(key: "test_key", value: "another_value")
    assert_not config.valid?
  end

  test "should get and set values" do
    # Set a value
    SystemConfig.set("test_key", "test_value")

    # Get the value
    assert_equal "test_value", SystemConfig.get("test_key")

    # Get a non-existent value with default
    assert_equal "default_value", SystemConfig.get("non_existent_key", "default_value")

    # Get a non-existent value without default
    assert_nil SystemConfig.get("non_existent_key")

    # Update an existing value
    SystemConfig.set("test_key", "updated_value")
    assert_equal "updated_value", SystemConfig.get("test_key")
  end

  test "should get and set max_concurrent_jobs" do
    # Default value
    assert_equal 2, SystemConfig.max_concurrent_jobs

    # Set a new value
    SystemConfig.max_concurrent_jobs = 5
    assert_equal 5, SystemConfig.max_concurrent_jobs

    # Verify it's stored in the database
    assert_equal "5", SystemConfig.find_by(key: "max_concurrent_jobs").value
  end
end
