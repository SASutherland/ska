class Course < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: :teacher_id
  has_many :questions, dependent: :destroy
  has_many :registrations, dependent: :destroy

  has_many :group_courses
  has_many :groups, through: :group_courses

  accepts_nested_attributes_for :questions, allow_destroy: true

  validates :title, presence: true
  validate :validate_questions

  private

  def validate_questions
    if questions.empty?
      errors.add(:base, "The course must have at least one question.")
    end

    questions.each do |question|
      if question.content.blank?
        errors.add(:base, "All question fields must be filled in.")
      end

      question.answers.each do |answer|
        if answer.content.blank?
          errors.add(:base, "All answer fields must be filled in for each question.")
        end
      end
    end
  end
end
