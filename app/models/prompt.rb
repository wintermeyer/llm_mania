class Prompt < ApplicationRecord
  belongs_to :user
  has_many :llm_jobs, dependent: :destroy
  has_many :prompt_reports, dependent: :destroy

  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[waiting in_queue processing completed failed] }
  validates :hidden, inclusion: { in: [ true, false ] }
  validates :flagged, inclusion: { in: [ true, false ] }
  validates :private, inclusion: { in: [ true, false ] }
  validate :content_within_subscription_limit, if: -> { content.present? }

  scope :private_prompts, -> { where(private: true) }
  scope :public_prompts, -> { where(private: false) }

  # Create LLM jobs for this prompt based on the user's subscription
  # This is now handled by the controller when specific LLMs are selected
  def create_llm_jobs
    # Method kept for backward compatibility but no longer automatically called
    subscription = user.current_subscription&.subscription
    return unless subscription

    # Get the LLMs available in the user's subscription
    available_llms = subscription.llms.active

    # Create a job for each LLM
    available_llms.each do |llm|
      llm_jobs.create!(
        llm: llm,
        priority: subscription.priority,
        position: 0, # Will be set by the after_create callback in LlmJob
        status: "queued"
      )
    end

    # Update prompt status if jobs were created
    update!(status: "in_queue") if llm_jobs.any?
  end

  # Check if all jobs are completed or failed
  def update_status
    return if llm_jobs.empty?

    # Reload the jobs to ensure we have the latest status
    llm_jobs.reload

    # Check job statuses
    all_completed_or_failed = llm_jobs.all? { |job| %w[completed failed].include?(job.status) }
    any_processing = llm_jobs.any? { |job| job.status == "processing" }
    any_completed = llm_jobs.any? { |job| job.status == "completed" }

    if all_completed_or_failed
      if any_completed
        update!(status: "completed")
      else
        update!(status: "failed")
      end
    elsif any_processing
      update!(status: "processing")
    else
      update!(status: "in_queue")
    end
  end

  private

  def content_within_subscription_limit
    max_length = user.current_subscription&.subscription&.max_prompt_length || 2000
    if content.length > max_length
      errors.add(:content, :too_long, count: max_length)
    end
  end
end
