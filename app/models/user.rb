class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  before_save :auto_approve_admins
  after_commit :notify_admins_of_new_signup, on: :create
  after_commit :send_welcome_email, on: :update, if: :saved_change_to_approved?
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
  has_many :trial_starts, dependent: :destroy
  has_many :activity_logs, dependent: :nullify

  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :inactives, -> { not_deleted.where(role: "inactive") }
  scope :students, -> { not_deleted.where(role: "student") }
  scope :teachers, -> { not_deleted.where(role: "teacher") }
  scope :admins, -> { not_deleted.where(role: "admin") }
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }

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

  def display_identifier
    [full_name.presence, read_attribute(:email)].compact.join(" - ")
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

  def auto_approve_admins
    self.approved = true if admin? && !approved?
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
    return unless approved? && saved_change_to_approved?
    
    puts "sending welcome email to #{read_attribute(:email)}"
    UserMailer.welcome_email(self).deliver_later
  end

  def notify_admins_of_new_signup
    return if admin? # Don't notify for admin accounts
    AdminMailer.new_signup_request(self).deliver_later
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

  def soft_delete
    update_column(:deleted_at, Time.current)
  end

  def destroy
    soft_delete
    true
  end

  def deleted?
    deleted_at.present?
  end

  # Prevent deleted users and unapproved users from authenticating
  def active_for_authentication?
    super && !deleted? && approved?
  end

  def inactive_message
    return :deleted_account if deleted?
    return :unapproved_account unless approved?
    super
  end
end
