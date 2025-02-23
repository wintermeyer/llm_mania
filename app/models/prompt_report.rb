class PromptReport < ApplicationRecord
  belongs_to :prompt
  belongs_to :user

  validates :reason, presence: true, inclusion: { in: %w[spam offensive nsfw other] }
  validates :prompt_id, uniqueness: { scope: :user_id }
end
