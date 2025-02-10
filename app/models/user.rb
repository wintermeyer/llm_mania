class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  belongs_to :plan, optional: true

  validates :email, presence: true, uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  attribute :plan_id, :integer, default: -> { Plan.default.id }

  # Check if user is an admin
  def admin?
    is_admin
  end
end
