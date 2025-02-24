require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    response = build(:response)
    assert response.valid?
  end

  test "should require response text" do
    response = build(:response, response: nil)
    assert_not response.valid?
    assert_includes response.errors[:response], "can't be blank"
  end

  test "should belong to llm_job" do
    response = create(:response)
    assert_not_nil response.llm_job
  end

  test "should have many ratings" do
    response = create(:response_with_ratings)
    assert_equal 2, response.ratings.count
  end

  test "should destroy associated ratings when destroyed" do
    response = create(:response_with_ratings)
    assert_difference "Rating.count", -2 do
      response.destroy
    end
  end
end
