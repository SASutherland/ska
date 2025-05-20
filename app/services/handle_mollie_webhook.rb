class HandleMollieWebhook
  def initialize(payment_id)
    @payment_id = payment_id
  end

  def call
    log("Handling webhook for payment #{@payment_id}")
    mollie_payment = Mollie::Payment.get(@payment_id)
    metadata = mollie_payment.metadata
    user_id = metadata[:user_id]

    unless user_id.present?
      log("No metadata or missing user_id, skipping")
      return
    end

    user = User.find_by(id: user_id)
    unless user
      log("User not found with ID #{user_id}, skipping")
      return
    end

    subscription = user.active_subscription
    unless subscription
      log("No active subscription found for user #{user.id}, skipping")
      return
    end

    if mollie_payment.paid?
      subscription.update(status: :active, cancellation_reason: nil)
      PaymentMailer.payment_success(user).deliver_later
      log("Marked subscription as active")
    elsif %w[failed expired canceled charged_back].include?(mollie_payment.status)
      subscription.update(status: :canceled, cancellation_reason: mollie_payment.status)
      PaymentMailer.payment_failed(user, mollie_payment.status).deliver_later
      log("Marked subscription as canceled (#{mollie_payment.status})")
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
