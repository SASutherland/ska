class Group < ApplicationRecord
  belongs_to :teacher, class_name: "User"

  has_many :group_memberships, dependent: :destroy
  has_many :students, through: :group_memberships, source: :user

  has_many :group_courses, dependent: :destroy
  has_many :courses, through: :group_courses

  validates :name, presence: true

  validate :must_have_students
  validate :owner_must_be_authorized

  private

  def must_have_students
    errors.add(:base, "Groepen moeten ten minste één student bevatten") if student_ids.empty?
  end

  def owner_must_be_authorized
    unless teacher&.teacher? || teacher&.admin?
      errors.add(:base, "Alleen leraren en admins mogen groepen maken")
    end
  end
end
