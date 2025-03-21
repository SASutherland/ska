class HandleMollieWebhookJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    HandleMollieWebhook.new(payment_id).call
  rescue => e
    Rails.logger.error("[HandleMollieWebhookJob] Failed: #{e.message}")
    raise
  end
end
