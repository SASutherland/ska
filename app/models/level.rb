class Level < ApplicationRecord
  has_many :course_levels, dependent: :destroy
  has_many :courses, through: :course_levels

  validates :name, presence: true, uniqueness: true
end
