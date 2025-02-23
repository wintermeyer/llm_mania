class DailyUsage < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :prompt_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :date, uniqueness: { scope: :user_id }
end
