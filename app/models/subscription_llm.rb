class SubscriptionLlm < ApplicationRecord
  belongs_to :subscription
  belongs_to :llm

  validates :subscription_id, uniqueness: { scope: :llm_id }
end
