require "test_helper"

class LlmJobTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    llm_job = build(:llm_job)
    assert llm_job.valid?
  end

  test "should require priority" do
    llm_job = build(:llm_job, priority: nil)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:priority], "can't be blank"
  end

  test "should require valid priority" do
    llm_job = build(:llm_job, priority: -1)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:priority], "must be greater than or equal to 0"
  end

  test "should require position" do
    llm_job = build(:llm_job, position: nil)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:position], "can't be blank"
  end

  test "should require valid position" do
    llm_job = build(:llm_job, position: -1)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:position], "must be greater than or equal to 0"
  end

  test "should require status" do
    llm_job = build(:llm_job, status: nil)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:status], "can't be blank"
  end

  test "should require valid status" do
    llm_job = build(:llm_job, status: "invalid")
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:status], "is not included in the list"
  end

  test "should allow valid status values" do
    %w[queued processing failed].each do |status|
      llm_job = build(:llm_job, status: status)
      assert llm_job.valid?, "#{status} should be a valid status"
    end

    # Special case for completed status which requires a response
    llm_job = build(:llm_job, status: "completed", response: "This is a test response")
    assert llm_job.valid?, "completed should be a valid status"
  end

  test "should allow nil response_time_ms" do
    llm_job = build(:llm_job, response_time_ms: nil)
    assert llm_job.valid?
  end

  test "should require valid response_time_ms when present" do
    llm_job = build(:llm_job, response_time_ms: -1)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:response_time_ms], "must be greater than or equal to 0"
  end

  test "should belong to prompt" do
    llm_job = create(:llm_job)
    assert_not_nil llm_job.prompt
  end

  test "should belong to llm" do
    llm_job = create(:llm_job)
    assert_not_nil llm_job.llm
  end

  test "should require response when status is completed" do
    llm_job = build(:llm_job, status: "completed", response: nil)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:response], "can't be blank"
  end

  test "should not require response when status is not completed" do
    %w[queued processing failed].each do |status|
      llm_job = build(:llm_job, status: status, response: nil)
      assert llm_job.valid?, "response should not be required for status #{status}"
    end
  end

  test "should have many ratings" do
    llm_job = create(:completed_job_with_ratings)
    assert_equal 2, llm_job.ratings.count
  end

  test "should destroy associated ratings when destroyed" do
    llm_job = create(:completed_job_with_ratings)
    assert_difference "Rating.count", -2 do
      llm_job.destroy
    end
  end
end
