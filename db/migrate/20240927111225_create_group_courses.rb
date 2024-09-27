class CreateGroupCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :group_courses do |t|
      t.references :group, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end

    add_index :group_courses, [:group_id, :course_id], unique: true
  end
end
