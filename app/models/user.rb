class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  validates :email, presence: true, uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  # Check if user is an admin
  def admin?
    is_admin
  end
end
