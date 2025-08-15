class AddUniqueIndexToRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_index :registrations, [:user_id, :course_id], unique: true, name: "index_registrations_on_user_and_course_unique"
  end
end