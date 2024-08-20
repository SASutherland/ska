class Answer < ApplicationRecord
  belongs_to :question
  has_many :attempts, foreign_key: :chosen_answer_id, dependent: :destroy
end
