class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def new
    @memberships = Membership.all
  end

  def create
    membership = Membership.find(params[:membership_id])
    customer = Mollie::Customer.create(name: current_user.name, email: current_user.email)

    payment = Mollie::Payment.create(
      amount: {
        currency: "EUR",
        value: membership.price.to_s
      },
      description: "First payment for #{membership.name} plan",
      redirect_url: subscription_success_url,
      webhook_url: subscriptions_webhook_url,
      sequence_type: "first",
      customer_id: customer.id,
      metadata: {
        user_id: current_user.id,
        membership_id: membership.id
      }
    )

    # Save customer ID temporarily if needed
    session[:mollie_customer_id] = customer.id
    session[:selected_membership_id] = membership.id

    redirect_to payment.checkout_url
  end

  def success
    customer_id = session.delete(:mollie_customer_id)
    membership_id = session.delete(:selected_membership_id)
    membership = Membership.find(membership_id)

    customer = Mollie::Customer.get(customer_id)
    mandates = customer.mandates
    valid_mandate = mandates.find { |m| m.status == "valid" }

    if valid_mandate
      mollie_subscription = customer.subscriptions.create(
        amount: {
          currency: "EUR",
          value: membership.price.to_s
        },
        interval: membership.interval,
        description: "#{membership.name} Plan Subscription",
        webhook_url: subscriptions_webhook_url
      )

      current_user.create_subscription!(
        membership: membership,
        mollie_customer_id: customer_id,
        mollie_mandate_id: valid_mandate.id,
        mollie_subscription_id: mollie_subscription.id,
        status: "active",
        start_date: Date.today
      )

      redirect_to root_path, notice: "Subscription active!"
    else
      redirect_to root_path, alert: "Could not start recurring subscription"
    end
  end

  def webhook
    if params[:id].present?
      mollie_payment = Mollie::Payment.get(params[:id])
      user = User.find(mollie_payment.metadata.user_id)
      subscription = user.subscription

      if mollie_payment.is_paid?
        subscription.update(status: "active")
      elsif mollie_payment.is_failed? || mollie_payment.is_expired? || mollie_payment.is_canceled? || mollie_payment.status == "charged_back"
        subscription.update(status: "cancelled")
      end
    end

    head :ok
  end
end
