class StoreMolliePayment
  def initialize(mollie_payment, user:, subscription:)
    @mollie_payment = mollie_payment
    @user = user
    @subscription = subscription
  end

  def call
    return unless persistable_status?

    payment = Payment.find_or_initialize_by(mollie_id: @mollie_payment.id)
    payment.user = @user
    payment.subscription = @subscription
    payment.amount_cents = (@mollie_payment.amount.value.to_f * 100).to_i
    payment.amount_currency = @mollie_payment.amount.currency
    payment.status = @mollie_payment.status
    payment.description = @mollie_payment.description
    payment.paid_at = @mollie_payment.paid_at
    payment.save!

    payment
  end

  private

  def persistable_status?
    @mollie_payment.paid? || %w[failed expired canceled charged_back].include?(@mollie_payment.status)
  end
end
