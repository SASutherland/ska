class Level < ApplicationRecord
  has_many :course_levels, dependent: :destroy
  has_many :courses, through: :course_levels
  has_many :user_levels, dependent: :destroy
  has_many :users, through: :user_levels

  validates :name, presence: true, uniqueness: true
end
