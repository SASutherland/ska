class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validate :user_not_already_registered

  enum status: {
    in_progress: "in_progress",
    completed: "completed"
  }

  private

  def user_not_already_registered
    if Registration.exists?(user_id: user_id, course_id: course_id)
      errors.add(:base, "Je bent al ingeschreven voor deze cursus")
    end
  end
end
