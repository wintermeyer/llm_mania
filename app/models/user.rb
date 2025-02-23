class User < ApplicationRecord
  has_many :prompts, dependent: :destroy
  has_many :prompt_reports, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :subscription_histories
  belongs_to :current_subscription, class_name: 'SubscriptionHistory', optional: true
  has_many :daily_usages, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
