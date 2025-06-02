class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  monetize :amount_cents

  scope :successful, -> { where(status: "paid") }
end
