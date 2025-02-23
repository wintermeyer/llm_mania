class Subscription < ApplicationRecord
  has_many :subscription_histories, dependent: :destroy
  has_many :subscription_llms, dependent: :destroy
  has_many :llms, through: :subscription_llms

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :max_llm_requests_per_day, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }
  validates :max_prompt_length, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :private_prompts_allowed, inclusion: { in: [ true, false ] }
  validates :active, inclusion: { in: [ true, false ] }
end
