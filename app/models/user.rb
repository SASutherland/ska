class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  after_commit :send_welcome_email, on: :create
  after_initialize :set_default_role, if: :new_record?

  enum role: {inactive: 0, student: 1, teacher: 2, admin: 3}

  has_many :courses, foreign_key: :teacher_id, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :owned_groups, class_name: "Group", foreign_key: :teacher_id
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :subscriptions, dependent: :destroy
  has_many :memberships, through: :subscriptions
  has_many :payments

  scope :inactives, -> { where(role: "inactive") }
  scope :students, -> { where(role: "student") }
  scope :teachers, -> { where(role: "teacher") }
  scope :admins, -> { where(role: "admin") }

  validates :first_name, :last_name, presence: true

  def admin?
    role == "admin"
  end

  def teacher?
    role == "teacher"
  end

  def student?
    role == "student"
  end

  def inactive?
    role == "inactive"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_default_role
    self.role ||= :inactive
  end

  def active_subscription
    subscriptions.find_by(status: :active)
  end

  def mollie_customer
    return unless mollie_customer_id

    @mollie_customer ||= Mollie::Customer.get(mollie_customer_id)
  rescue Mollie::Exception => e
    Rails.logger.error("Failed to fetch Mollie customer: #{e.message}")
    nil
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
