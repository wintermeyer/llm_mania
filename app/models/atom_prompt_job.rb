# frozen_string_literal: true

class AtomPromptJob < ApplicationRecord
  include AASM

  belongs_to :prompt_job
  belongs_to :llm_model
  delegate :prompt, to: :prompt_job

  validates :state, presence: true
  validates :prompt_job_id, uniqueness: { scope: :llm_model_id }

  # Define scopes for different states
  scope :pending, -> { where(state: "pending") }
  scope :processing, -> { where(state: "processing") }
  scope :completed, -> { where(state: "completed") }
  scope :failed, -> { where(state: "failed") }

  # Define state machine
  aasm column: :state do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed

    event :process do
      transitions from: :pending, to: :processing, after: :process_prompt
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: [ :pending, :processing ], to: :failed
    end
  end

  def process_prompt
    update(started_at: Time.current)
    process_prompt_async
  end

  def process_prompt_async
    ProcessPromptJob.perform_later(id)
  end

  private

  def process_with_llm
    # Dummy implementation - replace with actual Ollama integration
    begin
      # Simulate processing time
      sleep(2)
      # Set a dummy response
      update!(
        response: "This is a dummy response for the prompt: #{prompt}",
        completed_at: Time.current
      )
      complete!
    rescue StandardError => e
      update!(error_message: e.message)
      fail!
    end
  end
end
