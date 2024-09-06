class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :send_welcome_email
  after_initialize :set_default_role, if: :new_record?

  enum role: { student: 0, teacher: 1 }

  has_many :courses, foreign_key: :teacher_id, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :registrations, dependent: :destroy

  def set_default_role
    self.role ||= :student
  end

  def teacher?
    role == "teacher"
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
