class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.references :teacher, null: false, foreign_key: {to_table: :users}, column: :teacher_id
      t.string :name

      t.timestamps
    end
  end
end
