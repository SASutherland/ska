class CreateAttemptsAnswersJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :attempts_answers, id: false do |t|
      t.references :attempt, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true
    end
  end
end
