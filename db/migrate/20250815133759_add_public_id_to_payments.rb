class AddPublicIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :public_id, :string
    add_index :payments, :public_id, unique: true
  end
end