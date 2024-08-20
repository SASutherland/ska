class Attempt < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :chosen_answer, class_name: 'Answer'
end
