class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum status: {
    in_progress: "in_progress",
    completed: "completed"
  }
end
