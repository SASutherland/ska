class PostmarkWebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :authenticate_basic_auth

  def webhook
    # Postmark sends webhook events as JSON in the request body
    # Rails automatically parses JSON into params when Content-Type is application/json
    event_type = params[:RecordType]
    
    # Only process delivery events
    if event_type == "Delivery"
      handle_delivery_event(params)
    end
    
    head :ok
  rescue => e
    Rails.logger.error("[PostmarkWebhook] Error processing webhook: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    head :ok # Always return 200 to prevent Postmark from retrying
  end

  private

  def authenticate_basic_auth
    username = postmark_webhook_username
    password = postmark_webhook_password
    
    # If credentials are configured, require basic auth
    if username.present? && password.present?
      authenticate_or_request_with_http_basic do |user, pass|
        ActiveSupport::SecurityUtils.secure_compare(user, username) &&
          ActiveSupport::SecurityUtils.secure_compare(pass, password)
      end
    end
  end

  def postmark_webhook_username
    Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :webhook, :username)
  end

  def postmark_webhook_password
    Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :webhook, :password)
  end

  def handle_delivery_event(data)
    recipient = data[:Recipient]
    message_id = data[:MessageID]
    delivered_at = data[:DeliveredAt]
    tag = data[:Tag]
    details = data[:Details]
    metadata = data[:Metadata] || {}
    server_id = data[:ServerID]
    message_stream = data[:MessageStream]
    
    # Try to find the user by email
    user = User.find_by(email: recipient) if recipient.present?
    
    # Create activity log entry
    ActivityLogger.log_email_delivered(
      user: user,
      recipient: recipient,
      message_id: message_id,
      delivered_at: delivered_at,
      tag: tag,
      details: details,
      metadata: metadata,
      server_id: server_id,
      message_stream: message_stream
    )
    
    Rails.logger.info("[PostmarkWebhook] Logged email delivery for #{recipient}")
  end
end

