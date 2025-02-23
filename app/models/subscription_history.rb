class SubscriptionHistory < ApplicationRecord
  belongs_to :subscription
  belongs_to :user
  has_one :current_user, class_name: 'User', foreign_key: 'current_subscription_id'

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
