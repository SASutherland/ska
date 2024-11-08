class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validate :user_must_be_a_student
  validates :user_id, uniqueness: {scope: :group_id, message: "Deze gebruiker is al lid van deze groep"}

  private

  def user_must_be_a_student
    errors.add(:user, "moet een student zijn") unless user&.student?
  end
end
