class Plan < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Configure money-rails
  monetize :price_cents, as: :price, with_currency: :eur

  has_many :plan_llm_models, dependent: :destroy
  has_many :llm_models, -> { order(:name) }, through: :plan_llm_models
  has_many :users, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true,
                  format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_active, inclusion: { in: [ true, false ] }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }

  # Scope for active plans
  scope :active, -> { where(is_active: true) }

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
