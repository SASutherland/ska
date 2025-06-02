class CreateMollieSubscription
  include Rails.application.routes.url_helpers

  def initialize(user:, membership:, customer:, valid_mandate:, host:)
    @user = user
    @membership = membership
    @customer = customer
    @mandate = valid_mandate
    @host = host
  end

  def call
    log("Creating subscription for user ##{@user.id}, plan '#{@membership.name}'")

    mollie_subscription = Mollie::Customer::Subscription.create(
      customer_id: @customer.id,
      amount: {
        currency: "EUR",
        value: format("%.2f", @membership.price)
      },
      interval: @membership.interval,
      description: "#{@membership.name} Plan Subscription – #{Time.current.strftime("%Y%m%d%H%M%S")}",
      webhook_url: subscriptions_webhook_url(host: @host, protocol: "https", port: nil),
      metadata: {
        user_id: @user.id
      }
    )

    @user.subscriptions.create!(
      membership: @membership,
      mollie_customer_id: @customer.id,
      mollie_mandate_id: @mandate.id,
      mollie_subscription_id: mollie_subscription.id,
      status: "active",
      start_date: Date.today
    )

    puts "ABOUT TO STREAM TO #{@user}"

    Turbo::StreamsChannel.broadcast_replace_to(
      @user,
      target: "subscription-status",
      partial: "subscriptions/status_success",
      locals: {subscription: @user.active_subscription}
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
