class Course < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: :teacher_id
  has_many :questions, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :users, through: :registrations

  has_many :group_courses, dependent: :destroy  
  has_many :groups, through: :group_courses

  has_many :course_levels, dependent: :destroy
  has_many :levels, through: :course_levels

  accepts_nested_attributes_for :questions, allow_destroy: true

  validates :title, presence: true
  validate :validate_questions

  private

  def validate_questions
    if questions.empty?
      errors.add(:base, "De cursus moet ten minste één vraag bevatten.")
    end

    questions.each do |question|
      if question.content.blank?
        errors.add(:base, "Alle vragen moeten ingevuld zijn")
      end

      question.answers.each do |answer|
        if answer.content.blank?
          errors.add(:base, "Alle antwoorden moeten ingevuld zijn")
        end
      end
    end
  end
end
