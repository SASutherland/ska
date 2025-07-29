class CreateCourseLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :course_levels do |t|
      t.references :course, null: false, foreign_key: true
      t.references :level, null: false, foreign_key: true

      t.timestamps
    end
  end
end
