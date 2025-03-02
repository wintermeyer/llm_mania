class PeriodicQueueCheckJob < ApplicationJob
  queue_as :default

  def perform
    # Process the queue
    QueueManagerJob.perform_now

    # Schedule the next check
    PeriodicQueueCheckJob.set(wait: 1.minute).perform_later
  end

  # Method to start the periodic check if it's not already running
  def self.ensure_scheduled
    # Check if there are any pending PeriodicQueueCheckJob jobs
    # This is compatible with GoodJob adapter
    pending_jobs = GoodJob::Job.where(job_class: name)
                               .where(finished_at: nil)
                               .where(error: nil)
                               .exists?

    # If no pending jobs, schedule one
    perform_later unless pending_jobs
  end
end
