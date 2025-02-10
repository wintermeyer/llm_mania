class PromptJob < ApplicationRecord
  belongs_to :user
  has_one :plan, through: :user
  has_many :plan_llm_models, through: :plan
  has_many :available_llm_models, through: :plan, source: :llm_models

  has_many :atom_prompt_jobs, dependent: :destroy
  has_many :llm_models, through: :atom_prompt_jobs

  validates :prompt, presence: true, length: { minimum: 10, maximum: 10000 }
  validates :llm_models, presence: { message: "must include at least one model" }
  validate :llm_models_must_be_available

  private

  def llm_models_must_be_available
    return if llm_models.empty?
    invalid_models = llm_models - available_llm_models
    if invalid_models.any?
      errors.add(:llm_models, "includes models that are not available in your plan: #{invalid_models.map(&:name).join(', ')}")
    end
  end
end
