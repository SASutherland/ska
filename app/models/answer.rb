class Answer < ApplicationRecord
  belongs_to :question
  has_and_belongs_to_many :attempts, join_table: 'attempts_answers', dependent: :destroy

  before_destroy :remove_attempts_with_chosen_answer

  private

  def remove_attempts_with_chosen_answer
    Attempt.where(chosen_answer_id: self.id).destroy_all
  end
end
