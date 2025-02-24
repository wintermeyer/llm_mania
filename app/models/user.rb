class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :prompts, dependent: :destroy
  has_many :prompt_reports, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :subscription_histories
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  belongs_to :current_role, class_name: "Role", optional: true

  def current_subscription
    subscription_histories.find_by("start_date <= ? AND end_date >= ?", Time.current, Time.current)
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[male female other] }
  validates :lang, presence: true, inclusion: { in: %w[en de] }
  validates :active, inclusion: { in: [ true, false ] }
end
