class Group < ApplicationRecord
  belongs_to :teacher, class_name: "User"

  has_many :group_memberships, dependent: :destroy
  has_many :students, through: :group_memberships, source: :user

  has_many :group_courses, dependent: :destroy
  has_many :courses, through: :group_courses

  validates :name, presence: true

  validate :must_have_students 
  validate :owner_must_be_a_teacher

  private

  def must_have_students
    errors.add(:base, "Groups must include at least one student") if student_ids.empty?
  end

  def owner_must_be_a_teacher
    errors.add(:base, "Only teachers can create a group") unless teacher&.teacher?
  end
end
