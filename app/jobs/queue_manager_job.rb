class QueueManagerJob < ApplicationJob
  queue_as :default

  # Use a mutex to prevent race conditions
  MUTEX = Mutex.new

  def perform
    MUTEX.synchronize do
      process_queue
    end
  end

  private

  def process_queue
    # Get the maximum number of concurrent jobs
    max_concurrent = get_max_concurrent_jobs

    # Count current processing jobs
    current_processing = LlmJob.processing.count

    # Calculate how many new jobs we can start
    slots_available = max_concurrent - current_processing

    # If no slots available, do nothing
    return if slots_available <= 0

    # Get the next jobs in the queue, ordered by priority (desc), position (asc), and created_at (asc)
    next_jobs = LlmJob.queued.limit(slots_available)

    # Process each job
    next_jobs.each do |job|
      ProcessLlmJob.perform_later(job.id)
    end
  end

  # Helper method to get max concurrent jobs with fallback if table doesn't exist
  def get_max_concurrent_jobs
    # Default value if we can't access the SystemConfig
    default_max_concurrent = 2

    # Check if the table exists before querying
    if ActiveRecord::Base.connection.table_exists?(:system_configs)
      begin
        SystemConfig.max_concurrent_jobs
      rescue => e
        Rails.logger.warn "Error accessing SystemConfig: #{e.message}. Using default value: #{default_max_concurrent}"
        default_max_concurrent
      end
    else
      Rails.logger.warn "SystemConfigs table does not exist yet. Using default max_concurrent_jobs: #{default_max_concurrent}"
      default_max_concurrent
    end
  end
end
