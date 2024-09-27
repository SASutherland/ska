class Group < ApplicationRecord
  belongs_to :teacher, class_name: "User"

  has_many :group_memberships
  has_many :students, through: :group_memberships, source: :user

  has_many :group_courses
  has_many :courses, through: :group_courses

  validate :owner_must_be_a_teacher

  private

  def owner_must_be_a_teacher
    errors.add(:teacher, "teacher_id must be a teacher-user") unless teacher&.teacher?
  end
end
