class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.string :mollie_customer_id
      t.string :mollie_mandate_id
      t.string :mollie_subscription_id
      t.string :status
      t.date :start_date

      t.timestamps
    end
  end
end
