class Course < ApplicationRecord
  belongs_to :teacher, class_name: 'User', foreign_key: :teacher_id
  has_many :questions, dependent: :destroy
  has_many :registrations, dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true
end
