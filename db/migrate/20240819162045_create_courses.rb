class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.string :description
      t.references :teacher, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
