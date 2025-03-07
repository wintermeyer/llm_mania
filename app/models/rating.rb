class Rating < ApplicationRecord
  belongs_to :llm_job
  belongs_to :user

  validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :llm_job_id, uniqueness: { scope: :user_id }
  validates :comment, presence: true
end
