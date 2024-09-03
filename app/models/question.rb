class Question < ApplicationRecord
  belongs_to :course
  has_many :answers, dependent: :destroy
  has_many :attempts, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true
end
