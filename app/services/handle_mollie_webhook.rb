class HandleMollieWebhook
  def initialize(payment_id)
    @payment_id = payment_id
  end

  def call
    log("Handling webhook for payment #{@payment_id}")
    mollie_payment = Mollie::Payment.get(@payment_id)
    metadata = mollie_payment.metadata
    user_id = metadata&.[](:user_id)
    membership_id = metadata&.[](:membership_id)

    unless user_id && membership_id
      log("Missing metadata (user_id or membership_id), skipping")
      return
    end

    user = User.find_by(id: user_id)
    membership = Membership.find_by(id: membership_id)

    unless user && membership
      log("User or membership not found, skipping")
      return
    end

    case mollie_payment.sequence_type
    when "first"
      handle_first_payment(user, membership, mollie_payment)
    when "recurring"
      handle_recurring_payment(user, mollie_payment)
    else
      log("Unhandled payment sequence_type: #{mollie_payment.sequence_type}")
    end
  rescue => e
    log("Error: #{e.message}")
    raise
  end

  private

  def handle_first_payment(user, membership, mollie_payment)
    if user.active_subscription.present?
      log("User already has an active subscription, skipping creation.")
      return
    end

    customer = Mollie::Customer.get(mollie_payment.customer_id)
    valid_mandate = customer.mandates.find { |m| m.status == "valid" }

    if valid_mandate && mollie_payment.status == "paid"
      ActiveRecord::Base.transaction do
        subscription = CreateMollieSubscription.new(
          user: user,
          membership: membership,
          customer: customer,
          valid_mandate: valid_mandate,
          host: Rails.application.config.x.default_host.presence || Rails.application.credentials.dig(Rails.env.to_sym, :default_host)
        ).call
        StoreMolliePayment.new(mollie_payment, user: user, subscription: subscription).call
        PaymentMailer.payment_success(user).deliver_later

        log("Subscription created successfully for user #{user.id}")
      end
    else
      log("Mandate or payment not valid for first payment")
      PaymentMailer.payment_failed(user, mollie_payment.status).deliver_later
    end
  end

  def handle_recurring_payment(user, mollie_payment)
    subscription = user.active_subscription
    unless subscription
      log("No active subscription found for user #{user.id}, skipping")
      return
    end

    if mollie_payment.paid?
      ActiveRecord::Base.transaction do
        StoreMolliePayment.new(mollie_payment, user: user, subscription: subscription).call
        subscription.update!(status: :active, cancellation_reason: nil)
        log("Marked subscription as active")
      end
      PaymentMailer.payment_success(user).deliver_later
    elsif %w[failed expired canceled charged_back].include?(mollie_payment.status)
      ActiveRecord::Base.transaction do
        subscription.update!(status: :canceled, cancellation_reason: mollie_payment.status)
        PaymentMailer.payment_failed(user, mollie_payment.status).deliver_later
        log("Marked subscription as canceled (#{mollie_payment.status})")
      end
    else
      log("Unhandled status: #{mollie_payment.status}")
    end
  end

  def log(msg)
    Rails.logger.info("[HandleMollieWebhook] #{msg}")
  end
end
