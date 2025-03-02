class SystemConfig < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  # Get a configuration value by key
  def self.get(key, default = nil)
    config = find_by(key: key)
    config ? config.value : default
  end

  # Set a configuration value
  def self.set(key, value)
    config = find_or_initialize_by(key: key)
    config.update!(value: value.to_s)
  end

  # Get the maximum number of concurrent LLM jobs
  def self.max_concurrent_jobs
    get("max_concurrent_jobs", 2).to_i
  end

  # Set the maximum number of concurrent LLM jobs
  def self.max_concurrent_jobs=(value)
    set("max_concurrent_jobs", value)
  end
end
