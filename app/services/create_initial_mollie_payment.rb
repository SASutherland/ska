class CreateInitialMolliePayment
  def initialize(user:, membership:, customer_id:, redirect_url:, webhook_url:)
    @user = user
    @membership = membership
    @customer_id = customer_id
    @redirect_url = redirect_url
    @webhook_url = webhook_url
  end

  def call
    log("Creating initial payment for user ##{@user.id}, membership '#{@membership.name}'")
    Mollie::Payment.create(
      amount: {
        currency: "EUR",
        value: format("%.2f", @membership.price)
      },
      description: "Eerste betaling voor #{@membership.name} lidmaatschap",
      redirect_url: @redirect_url,
      webhook_url: @webhook_url,
      sequence_type: "first",
      customer_id: @customer_id,
      metadata: {
        user_id: @user.id,
        membership_id: @membership.id

      }
    )
  rescue => e
    log("Error: #{e.message}")
    raise
  end

  private

  def log(msg)
    Rails.logger.info("[CreateInitialMolliePayment] #{msg}")
  end
end
