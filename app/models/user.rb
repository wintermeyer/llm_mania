class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[male female other] }
  validates :lang, presence: true, inclusion: { in: %w[en de] }

  before_validation :set_default_lang

  private

  def set_default_lang
    self.lang ||= "en"
  end
end
