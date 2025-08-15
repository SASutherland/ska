class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  monetize :amount_cents

  scope :successful, -> { where(status: "paid") }

  before_create :set_public_id

  private

  def set_public_id
    self.public_id = SecureRandom.hex(6)
  end
end
