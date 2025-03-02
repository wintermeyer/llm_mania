# Configure ActiveJob to use the PostgreSQL adapter for queuing
Rails.application.config.active_job.queue_adapter = :good_job

# Start the periodic queue check when the application starts
Rails.application.config.after_initialize do
  # Only start the periodic check in a server process
  if defined?(Rails::Server) || Rails.env.test?
    # Ensure we have a default max_concurrent_jobs setting
    unless SystemConfig.find_by(key: "max_concurrent_jobs")
      SystemConfig.create!(key: "max_concurrent_jobs", value: "2")
    end

    # Start the periodic queue check
    PeriodicQueueCheckJob.ensure_scheduled
  end
end
