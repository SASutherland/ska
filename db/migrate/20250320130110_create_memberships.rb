class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.string :name
      t.decimal :price
      t.string :interval

      t.timestamps
    end
  end
end
