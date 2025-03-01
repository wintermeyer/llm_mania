class Llm < ApplicationRecord
  has_many :llm_jobs, dependent: :destroy
  has_many :subscription_llms, dependent: :destroy
  has_many :subscriptions, through: :subscription_llms

  validates :name, presence: true, uniqueness: true
  validates :ollama_model, presence: true, uniqueness: true
  validates :size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 20 }
  validates :active, inclusion: { in: [ true, false ] }
  validates :creator, presence: true

  scope :active, -> { where(active: true) }
end
