class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :membership
  has_many :payments

  after_commit :update_user_role_based_on_subscription

  enum status: {
    pending: "pending",
    active: "active",
    canceled: "canceled",
    suspended: "suspended",
    completed: "completed"
  }

  private

  def update_user_role_based_on_subscription
    return if user.admin?

    new_role = if user.active_subscription
      case user.active_subscription.membership.name
      when "Docenten" then :teacher
      when "Basis" then :student
      else :inactive
      end
    else
      :inactive
    end

    user.update(role: new_role) if user.role != new_role
  end
end
