class Course < ApplicationRecord
  belongs_to :user, foreign_key: :teacher_id
  has_many :questions, dependent: :destroy
  has_many :registrations, dependent: :destroy
end
