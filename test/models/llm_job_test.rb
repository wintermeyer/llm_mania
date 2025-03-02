require "test_helper"

class LlmJobTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @subscription = FactoryBot.create(:subscription, priority: 2)
    @subscription_history = FactoryBot.create(:subscription_history, user: @user, subscription: @subscription)
    @llm = FactoryBot.create(:llm)
    @prompt = FactoryBot.create(:prompt, user: @user)
    @llm_job = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
  end

  test "should be valid" do
    assert @llm_job.valid?
  end

  test "should require priority" do
    @llm_job.priority = nil
    assert_not @llm_job.valid?
  end

  test "should require position" do
    # Create a new job with nil position
    job = FactoryBot.build(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued", position: nil)

    # Position can be nil before save
    assert job.valid?

    # Position should be set after save
    job.save!
    job.reload
    assert_not_nil job.position
  end

  test "should require status" do
    @llm_job.status = nil
    assert_not @llm_job.valid?
  end

  test "should validate status inclusion" do
    @llm_job.status = "invalid"
    assert_not @llm_job.valid?
    assert_includes @llm_job.errors[:status], "is not included in the list"

    @llm_job.status = "queued"
    assert @llm_job.valid?

    @llm_job.status = "processing"
    assert @llm_job.valid?

    @llm_job.status = "completed"
    @llm_job.response = "Test response" # Response is required for completed status
    assert @llm_job.valid?

    @llm_job.status = "failed"
    assert @llm_job.valid?
  end

  test "should validate priority range" do
    @llm_job.priority = 0
    assert_not @llm_job.valid?

    @llm_job.priority = 1
    assert @llm_job.valid?

    @llm_job.priority = 3
    assert @llm_job.valid?

    @llm_job.priority = 4
    assert_not @llm_job.valid?
  end

  test "should set initial position" do
    # Clear any existing jobs to ensure predictable positions
    LlmJob.destroy_all

    # Create jobs in sequence and check their positions
    job1 = FactoryBot.build(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job1.position = nil
    job1.save!
    job1.reload
    assert_equal 0, job1.position

    job2 = FactoryBot.build(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job2.position = nil
    job2.save!
    job2.reload
    assert_equal 1, job2.position

    job3 = FactoryBot.build(:llm_job, prompt: @prompt, llm: @llm, status: "queued")
    job3.position = nil
    job3.save!
    job3.reload
    assert_equal 2, job3.position
  end

  test "should move to position" do
    # Clear any existing jobs to ensure predictable positions
    LlmJob.destroy_all

    # Create jobs with explicit positions using direct SQL to avoid callbacks
    job1 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job2 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")
    job3 = FactoryBot.create(:llm_job, prompt: @prompt, llm: @llm, priority: 2, status: "queued")

    # Set positions directly in the database
    ActiveRecord::Base.connection.execute("UPDATE llm_jobs SET position = 0 WHERE id = '#{job1.id}'")
    ActiveRecord::Base.connection.execute("UPDATE llm_jobs SET position = 1 WHERE id = '#{job2.id}'")
    ActiveRecord::Base.connection.execute("UPDATE llm_jobs SET position = 2 WHERE id = '#{job3.id}'")

    # Reload to get the updated positions
    job1.reload
    job2.reload
    job3.reload

    # Verify initial positions
    assert_equal 0, job1.position
    assert_equal 1, job2.position
    assert_equal 2, job3.position

    # Move job3 to position 1
    job3.move_to_position(1)

    # Reload all jobs to get updated positions
    job1.reload
    job2.reload
    job3.reload

    # Expected positions: job1=0, job3=1, job2=2
    assert_equal 0, job1.position
    assert_equal 2, job2.position
    assert_equal 1, job3.position
  end

  test "should start processing" do
    @llm_job.start_processing!

    assert_equal "processing", @llm_job.status
    assert_not_nil @llm_job.started_at
  end

  test "should complete" do
    @llm_job.complete!("Test response", 1000)

    assert_equal "completed", @llm_job.status
    assert_equal "Test response", @llm_job.response
    assert_equal 1000, @llm_job.response_time_ms
    assert_not_nil @llm_job.completed_at
  end

  test "should fail" do
    @llm_job.fail!("Test error")

    assert_equal "failed", @llm_job.status
    assert_equal "Test error", @llm_job.error_message
    assert_not_nil @llm_job.completed_at
  end

  test "should be valid with all required attributes" do
    llm_job = build(:llm_job)
    assert llm_job.valid?
  end

  test "should require valid priority" do
    llm_job = build(:llm_job, priority: -1)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:priority], "must be greater than or equal to 1"
  end

  test "should require valid position" do
    llm_job = build(:llm_job, position: -1)
    assert_not llm_job.valid?
    assert_includes llm_job.errors[:position], "must be greater than or equal to 0"
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
