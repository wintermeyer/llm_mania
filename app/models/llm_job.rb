class LlmJob < ApplicationRecord
  belongs_to :prompt
  belongs_to :llm
  has_many :responses, dependent: :destroy

  validates :priority, presence: true, numericality: { only_integer: true }
  validates :position, presence: true, numericality: { only_integer: true }
  validates :status, presence: true, inclusion: { in: %w[queued processing completed failed] }

  scope :queued, -> { where(status: "queued") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
end
