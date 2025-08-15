class AddTrialFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :trial_courses_count, :integer
    add_column :users, :trial_active, :boolean
  end
end
