class Prompt < ApplicationRecord
  belongs_to :user
  has_many :llm_jobs, dependent: :destroy
  has_many :prompt_reports, dependent: :destroy

  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[waiting in_queue processing completed failed] }
  validates :hidden, inclusion: { in: [true, false] }
  validates :flagged, inclusion: { in: [true, false] }

  scope :private_prompts, -> { where(private: true) }
  scope :public_prompts, -> { where(private: false) }
end
