class AddTimeSpentToRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :registrations, :time_spent, :integer
  end
end
