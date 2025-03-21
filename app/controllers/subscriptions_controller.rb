class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    membership = Membership.find(params[:membership_id])
    customer = if current_user.mollie_customer_id.present?
      Mollie::Customer.get(current_user.mollie_customer_id)
    else
      CreateMollieCustomer.new(current_user).call.tap do |c|
        current_user.update!(mollie_customer_id: c.id)
      end
    end

    payment = CreateInitialMolliePayment.new(
      user: current_user,
      membership: membership,
      customer_id: customer.id,
      redirect_url: subscription_success_url,
      webhook_url: subscriptions_webhook_url
    ).call

    session[:mollie_customer_id] = customer.id
    session[:selected_membership_id] = membership.id

    redirect_to payment.checkout_url, allow_other_host: true
  end

  def success
    customer_id = session.delete(:mollie_customer_id)
    membership_id = session.delete(:selected_membership_id)
    membership = Membership.find(membership_id)
    customer = Mollie::Customer.get(customer_id)
    valid_mandate = customer.mandates.find { |m| m.status == "valid" }

    if valid_mandate
      CreateMollieSubscription.new(
        user: current_user,
        membership: membership,
        customer: customer,
        valid_mandate: valid_mandate
      ).call

      redirect_to root_path, notice: "Subscription active!"
    else
      redirect_to root_path, alert: "Could not start subscription."
    end
  end

  skip_before_action :verify_authenticity_token, only: [:webhook]
  def webhook
    HandleMollieWebhookJob.perform_later(params[:id])
    head :ok
  end
end
