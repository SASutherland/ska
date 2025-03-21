class HandleMollieWebhook
  def initialize(payment_id)
    @payment_id = payment_id
  end

  def call
    log("Handling webhook for payment #{@payment_id}")
    mollie_payment = Mollie::Payment.get(@payment_id)
    metadata = mollie_payment.metadata
    return log("No metadata, skipping") unless metadata&.user_id

    user = User.find(metadata.user_id)
    subscription = user.subscription

    if mollie_payment.paid?
      subscription.update(status: "active")
      log("Marked subscription as active")
    elsif %w[failed expired canceled charged_back].include?(mollie_payment.status)
      subscription.update(status: "cancelled")
      log("Marked subscription as cancelled (#{mollie_payment.status})")
    else
      log("Unhandled status: #{mollie_payment.status}")
    end
  rescue => e
    log("Error: #{e.message}")
    raise
  end

  private

  def log(msg)
    Rails.logger.info("[HandleMollieWebhook] #{msg}")
  end
end
