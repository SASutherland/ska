class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validate :user_not_already_registered

  enum status: {
    in_progress: "in_progress",
    completed: "completed"
  }

  scope :with_active_users, -> { joins(:user).where(users: { deleted_at: nil }) }

  private

  def user_not_already_registered
    if Registration.where(user_id: user_id, course_id: course_id).where.not(id: id).exists?
      errors.add(:base, "Je bent al ingeschreven voor deze cursus")
    end
  end
end
