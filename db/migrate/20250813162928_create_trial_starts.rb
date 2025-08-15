# db/migrate/20250813xxxxxx_create_trial_starts.rb
class CreateTrialStarts < ActiveRecord::Migration[7.0]
  def change
    create_table :trial_starts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :source # e.g., "start_button", "first_attempt"
      t.timestamps
    end

    add_index :trial_starts, [:user_id, :course_id], unique: true
  end
end
