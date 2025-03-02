class LlmJob < ApplicationRecord
  belongs_to :prompt
  belongs_to :llm
  has_many :ratings, dependent: :destroy

  validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[queued processing completed failed] }
  validates :response_time_ms, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :response, presence: true, if: -> { status == "completed" }

  scope :queued, -> { where(status: "queued").order(priority: :desc, position: :asc, created_at: :asc) }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  after_create :set_initial_position

  # Move job to a specific position in the queue
  def move_to_position(new_position)
    return if status != "queued" || new_position == position

    transaction do
      if new_position < position
        # Moving up in the queue
        LlmJob.queued
              .where("position >= ? AND position < ?", new_position, position)
              .update_all("position = position + 1")
      else
        # Moving down in the queue
        LlmJob.queued
              .where("position > ? AND position <= ?", position, new_position)
              .update_all("position = position - 1")
      end

      update!(position: new_position)
    end
  end

  # Start processing this job
  def start_processing!
    update!(status: "processing", started_at: Time.current)
  end

  # Mark job as completed
  def complete!(response_text, time_ms)
    update!(
      status: "completed",
      response: response_text,
      response_time_ms: time_ms,
      completed_at: Time.current
    )
  end

  # Mark job as failed
  def fail!(error_message)
    update!(
      status: "failed",
      error_message: error_message,
      completed_at: Time.current
    )
  end

  private

  def set_initial_position
    # Only set position if it's not already set
    return unless position.nil? || position.zero?

    # Set the initial position to be at the end of the queue
    # Use a direct SQL query to avoid race conditions
    max_position = LlmJob.where(status: "queued").maximum(:position)

    # If this is the first job, set position to 0
    new_position = max_position.nil? ? 0 : max_position + 1

    # Update without callbacks to avoid infinite loop
    update_column(:position, new_position)
  end
end
