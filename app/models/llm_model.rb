class LlmModel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true,
                  format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :is_active, inclusion: { in: [ true, false ] }
  validates :ollama_name, presence: true, uniqueness: true,
                         format: { with: /\A[a-z0-9:.-]+\z/, message: "only allows lowercase letters, numbers, dots, hyphens, and colons" }

  # Customize the slug generation
  def normalize_friendly_id(text)
    text.to_s.parameterize
  end

  # Generate a new slug if name changes
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  # Use slug in URLs instead of ID
  def to_param
    slug
  end

  def self.find_by_param(param)
    find_by!(slug: param)
  end
end
