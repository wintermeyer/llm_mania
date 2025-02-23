class Response < ApplicationRecord
  belongs_to :llm_job
  has_many :ratings, dependent: :destroy

  validates :content, presence: true
end
