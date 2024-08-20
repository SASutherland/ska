class CreateAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :attempts do |t|
      t.references :user, foreign_key: true
      t.references :question, foreign_key: true
      t.references :chosen_answer, foreign_key: { to_table: :answers }

      t.timestamps
    end
  end
end
