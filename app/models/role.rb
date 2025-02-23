class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :users_as_current_role, class_name: "User", foreign_key: :current_role_id

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :active, inclusion: { in: [true, false] }
end
