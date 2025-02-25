require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    rating = build(:rating)
    assert rating.valid?
  end

  test "should require score" do
    rating = build(:rating, score: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "can't be blank"
  end

  test "should require valid score" do
    rating = build(:rating, score: 0)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "must be greater than or equal to 1"

    rating = build(:rating, score: 6)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "must be less than or equal to 5"
  end

  test "should require integer score" do
    rating = build(:rating, score: 3.5)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "must be an integer"
  end

  test "should require comment" do
    rating = build(:rating, comment: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:comment], "can't be blank"
  end

  test "should belong to llm_job" do
    rating = create(:rating)
    assert_not_nil rating.llm_job
  end

  test "should belong to user" do
    rating = create(:rating)
    assert_not_nil rating.user
  end

  test "should enforce uniqueness of user and llm_job" do
    rating = create(:rating)
    duplicate = build(:rating, user: rating.user, llm_job: rating.llm_job)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:llm_job_id], "has already been taken"
  end
end
