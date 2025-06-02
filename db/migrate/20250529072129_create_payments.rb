class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.string :mollie_id
      t.references :user, null: false, foreign_key: true
      t.references :subscription, null: false, foreign_key: true
      t.integer :amount_cents
      t.string :amount_currency
      t.string :status
      t.string :description
      t.datetime :paid_at

      t.timestamps
    end
    add_index :payments, :mollie_id
  end
end
