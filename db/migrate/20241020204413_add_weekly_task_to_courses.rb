class AddWeeklyTaskToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :weekly_task, :boolean, default: false
  end
end
