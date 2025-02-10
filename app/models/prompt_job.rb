class PromptJob < ApplicationRecord
  belongs_to :user
  has_one :plan, through: :user
  has_many :plan_llm_models, through: :plan
  has_many :available_llm_models, through: :plan, source: :llm_models

  validates :prompt, presence: true, length: { minimum: 10, maximum: 10000 }
end
