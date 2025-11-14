class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :action, :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_subject, ->(subject) { where(subject: subject) }

  def metadata
    super || {}
  end
end

