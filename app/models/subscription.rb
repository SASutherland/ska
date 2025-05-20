class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :membership

  enum status: {
    pending: "pending",
    active: "active",
    canceled: "canceled",
    suspended: "suspended",
    completed: "completed"
  }
end
