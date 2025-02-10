# frozen_string_literal: true

class PromptJobLlmModel < ApplicationRecord
  belongs_to :prompt_job
  belongs_to :llm_model

  validates :prompt_job_id, uniqueness: { scope: :llm_model_id }
end
