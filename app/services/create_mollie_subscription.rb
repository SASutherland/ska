class CreateMollieSubscription
  def initialize(user:, membership:, customer:, valid_mandate:)
    @user = user
    @membership = membership
    @customer = customer
    @mandate = valid_mandate
  end

  def call
    log("Creating subscription for user ##{@user.id}, plan '#{@membership.name}'")

    mollie_subscription = @customer.subscriptions.create(
      amount: {
        currency: "EUR",
        value: format("%.2f", @membership.price)
      },
      interval: @membership.interval,
      description: "#{@membership.name} Plan Subscription",
      webhook_url: Rails.application.routes.url_helpers.subscriptions_webhook_url
    )

    @user.create_subscription!(
      membership: @membership,
      mollie_customer_id: @customer.id,
      mollie_mandate_id: @mandate.id,
      mollie_subscription_id: mollie_subscription.id,
      status: "active",
      start_date: Date.today
    )

    log("Subscription created with Mollie ID #{mollie_subscription.id}")
  rescue => e
    log("Error: #{e.message}")
    raise
  end

  private

  def log(msg)
    Rails.logger.info("[CreateMollieSubscription] #{msg}")
  end
end
