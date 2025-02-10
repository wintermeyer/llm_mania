class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :plan, optional: true
  has_many :prompt_jobs, dependent: :destroy
  has_many :plan_llm_models, through: :plan
  has_many :available_llm_models, through: :plan, source: :llm_models

  validates :email, presence: true, uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  attribute :plan_id, :integer, default: -> { Plan.default.id }

  # Check if user is an admin
  def admin?
    is_admin
  end
end
