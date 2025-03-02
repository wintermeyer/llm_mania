require "test_helper"

class PeriodicQueueCheckJobTest < ActiveJob::TestCase
  setup do
    # Clear any existing jobs
    GoodJob::Job.delete_all
  end

  test "should process the queue and schedule the next check" do
    # Create a spy on QueueManagerJob
    queue_manager_called = false
    QueueManagerJob.stub(:perform_now, -> { queue_manager_called = true }) do
      # Run the periodic check
      PeriodicQueueCheckJob.perform_now

      # Should have called QueueManagerJob
      assert queue_manager_called

      # Should have scheduled the next check
      assert_equal 1, GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").count

      # The next check should be scheduled for approximately 1 minute later
      next_job = GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").first
      scheduled_at = Time.parse(next_job.serialized_params["scheduled_at"])
      assert_in_delta 1.minute.from_now.to_i, scheduled_at.to_i, 5
    end
  end

  test "should ensure only one periodic check is scheduled" do
    # Make sure there are no jobs
    GoodJob::Job.delete_all

    # Schedule a periodic check
    PeriodicQueueCheckJob.ensure_scheduled

    # Should have scheduled a job
    assert_equal 1, GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").count

    # Try to schedule another one
    PeriodicQueueCheckJob.ensure_scheduled

    # Should still only have one job scheduled
    assert_equal 1, GoodJob::Job.where(job_class: "PeriodicQueueCheckJob").count
  end
end
