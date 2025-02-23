class Llm < ApplicationRecord
  has_many :llm_jobs, dependent: :destroy
  has_many :subscription_llms, dependent: :destroy
  has_many :subscriptions, through: :subscription_llms

  validates :name, presence: true, uniqueness: true
  validates :ollama_model, presence: true, uniqueness: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
end
