class Attempt < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_and_belongs_to_many :chosen_answers, class_name: 'Answer', join_table: 'attempts_answers'
end
