require "test_helper"

class PeriodicQueueCheckJobTest < ActiveJob::TestCase
  setup do
    # Clear any existing jobs
    GoodJob::Job.delete_all
  end

  test "should process the queue and schedule the next check" do
    # Create a stub for QueueManagerJob using mocha
    QueueManagerJob.expects(:perform_now).once

    # Run the periodic check
    PeriodicQueueCheckJob.perform_now

    # Should have scheduled the next check
    assert_equal 1, GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").count

    # The next check should be scheduled for approximately 1 minute later
    next_job = GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").first
    scheduled_at = Time.parse(next_job.serialized_params["scheduled_at"])
    assert_in_delta 1.minute.from_now.to_i, scheduled_at.to_i, 5
  end

  test "should ensure only one periodic check is scheduled" do
    # Make sure there are no jobs
    GoodJob::Job.delete_all

    # Mock the exists? method to control the behavior
    query_mock = mock
    GoodJob::Job.stubs(:where).with(job_class: PeriodicQueueCheckJob.name).returns(query_mock)
    query_mock.stubs(:where).with(finished_at: nil).returns(query_mock)
    query_mock.stubs(:where).with(error: nil).returns(query_mock)

    # First call, no jobs exist
    query_mock.stubs(:exists?).returns(false)

    # We need to stub perform_later to avoid actually creating jobs
    PeriodicQueueCheckJob.expects(:perform_later).once

    # This should schedule a job
    PeriodicQueueCheckJob.ensure_scheduled

    # Now pretend a job exists
    query_mock.stubs(:exists?).returns(true)

    # This should not schedule a job
    PeriodicQueueCheckJob.ensure_scheduled
  end
end
