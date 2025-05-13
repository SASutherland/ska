class AddMollieCustomerIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :mollie_customer_id, :string
  end
end
