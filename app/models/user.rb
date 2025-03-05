class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :prompts, dependent: :destroy
  has_many :prompt_reports, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :subscription_histories
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  belongs_to :current_role, class_name: "Role", optional: true

  after_initialize :set_default_gender, if: :new_record?
  after_initialize :set_default_language, if: :new_record?
  after_create :assign_default_role
  after_create :assign_roles_to_first_user, if: -> { Rails.env.development? }
  after_create :assign_cheapest_subscription
  before_validation :ensure_current_role

  def current_subscription
    subscription_histories.find_by("start_date <= ? AND end_date >= ?", Time.current, Time.current)
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[male female other] }
  validates :lang, presence: true, inclusion: { in: %w[en de] }
  validates :active, inclusion: { in: [ true, false ] }

  # Check if the user has a specific role
  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  # Check if the user is an admin
  def admin?
    has_role?("admin")
  end

  # Update user's language preference when they change the locale
  def update_language_preference(locale)
    update(lang: locale.to_s) if locale.to_s.in?(%w[en de])
  end

  private

  # Ensure the user always has a current role set
  # Always prioritize the "user" role when in doubt
  def ensure_current_role
    # Skip if current_role is already set or if this is a new record
    # New records will be handled by assign_default_role after create
    return if current_role.present? || new_record?

    # Always prioritize the "user" role
    if has_role?("user")
      user_role = roles.find_by(name: "user")
      self.current_role = user_role if user_role.present?
    elsif roles.any?
      # If no user role, just take the first one
      self.current_role = roles.first
    end
  end

  def set_default_gender
    self.gender ||= "male"
  end

  def set_default_language
    self.lang ||= I18n.locale.to_s
  end

  # Assign the cheapest subscription to the user
  def assign_cheapest_subscription
    # Skip if the user already has a subscription history
    return if subscription_histories.exists?

    # Find the cheapest active subscription
    cheapest_subscription = Subscription.where(active: true)
                                       .order(:price_cents, :created_at)
                                       .first

    # If no subscription is available, do nothing
    return if cheapest_subscription.nil?

    # Create a subscription history for one year from now
    subscription_histories.create!(
      subscription: cheapest_subscription,
      start_date: Time.current,
      end_date: 1.year.from_now
    )
  end

  # Assign the default user role to every new user
  # This method ensures that:
  # 1. Every user has the "user" role
  # 2. current_role is set to "user" if not explicitly provided
  def assign_default_role
    # Find or create the user role
    user_role = Role.find_or_create_by!(name: "user") do |role|
      role.description = "Regular user role with standard access"
      role.active = true
    end

    # Always assign the user role if not already assigned
    self.roles << user_role unless self.roles.include?(user_role)

    # Set current_role to user_role if not explicitly set during creation
    self.update(current_role: user_role) if self.current_role.nil?
  end

  # Assign both user and admin roles to the first user in development environment
  def assign_roles_to_first_user
    # Only proceed if this is the first user
    return unless User.count == 1

    # Find or create the roles
    user_role = Role.find_or_create_by!(name: "user") do |role|
      role.description = "Regular user role with standard access"
      role.active = true
    end

    admin_role = Role.find_or_create_by!(name: "admin") do |role|
      role.description = "Administrator role with full access"
      role.active = true
    end

    # Assign both roles to the user
    self.roles << user_role unless self.roles.include?(user_role)
    self.roles << admin_role unless self.roles.include?(admin_role)

    # Keep the current role as user (handled by assign_default_role)
    # No need to set current_role here as assign_default_role already sets it
  end
end
