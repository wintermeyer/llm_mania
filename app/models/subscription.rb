class Subscription < ApplicationRecord
  has_many :subscription_histories, dependent: :destroy
  has_many :subscription_llms, dependent: :destroy
  has_many :llms, through: :subscription_llms

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :daily_prompt_limit, presence: true, numericality: { greater_than: 0 }
end
