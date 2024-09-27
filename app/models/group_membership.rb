class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validate :user_must_be_a_student

  private

  def user_must_be_a_student
    errors.add(:user, "must be a student") unless user&.student?
  end
end
