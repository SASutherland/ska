class CreateLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :levels do |t|
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
