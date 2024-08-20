class Question < ApplicationRecord
  belongs_to :course
  has_many :answers, dependent: :destroy
  has_many :attempts, dependent: :destroy
end
