class AddWrittenAnswerToAttempts < ActiveRecord::Migration[7.0]
  def change
    add_column :attempts, :written_answer, :string
  end
end
