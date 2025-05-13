class AddCancellationReasonToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :cancellation_reason, :string
  end
end
