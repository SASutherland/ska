class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  after_commit :send_welcome_email, on: :create
  after_initialize :set_default_role, if: :new_record?

  enum role: { student: 0, teacher: 1, admin: 2 }

  has_many :courses, foreign_key: :teacher_id, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :owned_groups, class_name: "Group", foreign_key: :teacher_id
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  scope :students, -> { where(role: :student) }
  scope :teachers, -> { where(role: :teacher) }
  scope :admins, -> { where(role: :admin) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_default_role
    self.role ||= :student
  end

  def teacher?
    role == "teacher"
  end

  def student?
    role == "student"
  end

  def admin?
    role == "admin"
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
