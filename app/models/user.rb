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

  def email
    # remove after POSTMARK is configured
    "test@blackhole.postmarkapp.com"
  end

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

  def start_trial!
    update(role: :student, trial_active: true, trial_courses_count: 0)
  end

  def increment_trial_courses!
    increment!(:trial_courses_count) if trial_active?
  end

  def trial_limit_reached?
    trial_active? && trial_courses_count >= TrialConfig::TRIAL_LIMIT
  end

  def trial?
    trial_active? && active_subscription.nil?
  end

  def set_default_role
    self.role ||= "inactive"
  end

  def active_subscription
    subscriptions.find_by(status: "active")
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

  def has_completed?(course)
    questions = course.questions
    total_questions = questions.size
    total_attempts = attempts.where(question_id: questions.pluck(:id)).size

    total_questions == total_attempts && total_questions > 0
  end

  def score_for(course)
    questions = course.questions
    total_questions = questions.size

    correct_answers = attempts.where(question_id: questions.pluck(:id), correct: true).count

    percentage = total_questions.positive? ? (correct_answers.to_f / total_questions * 100).round : 0

    {
      correct: correct_answers,
      total: total_questions,
      percentage: percentage
    }
  end
end
