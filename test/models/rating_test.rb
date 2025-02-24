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

  test "should require valid score range" do
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

  test "should belong to response" do
    rating = create(:rating)
    assert_not_nil rating.response
  end

  test "should belong to user" do
    rating = create(:rating)
    assert_not_nil rating.user
  end

  test "should enforce unique user per response" do
    rating = create(:rating)
    duplicate_rating = build(:rating, user: rating.user, response: rating.response)
    assert_not duplicate_rating.valid?
    assert_includes duplicate_rating.errors[:response_id], "has already been taken"
  end
end
