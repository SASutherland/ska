class AddCorrectToAttempts < ActiveRecord::Migration[7.0]
  def change
    add_column :attempts, :correct, :boolean
  end
end
