class Response < ApplicationRecord
  belongs_to :llm_job
  has_many :ratings, dependent: :destroy

  validates :response, presence: true
end
