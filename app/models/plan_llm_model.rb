class PlanLlmModel < ApplicationRecord
  belongs_to :plan
  belongs_to :llm_model

  validates :plan_id, uniqueness: { scope: :llm_model_id }
end
