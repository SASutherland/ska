class Answer < ApplicationRecord
  belongs_to :question
  has_many :attempts, through: :attempts_answers, dependent: :destroy
end
