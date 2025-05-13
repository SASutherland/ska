class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook]

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
      webhook_url: "https://671e-178-224-82-116.ngrok-free.app/subscriptions/webhook"
    ).call

    session[:mollie_customer_id] = customer.id
    session[:selected_membership_id] = membership.id

    redirect_to payment.checkout_url, allow_other_host: true, status: :see_other
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

      redirect_to dashboard_subscriptions_path, notice: "Lidmaatschap is geactiveerd."
    else
      redirect_to dashboard_subscriptions_path, alert: "Kon lidmaatschap niet activeren."
    end
  end

  def cancel
    subscription = current_user.active_subscription

    if subscription.nil?
      redirect_to dashboard_subscriptions_path, alert: "Geen actief lidmaatschap gevonden."
      return
    end

    Mollie::Customer::Subscription.delete(
      subscription.mollie_subscription_id,
      customer_id: subscription.mollie_customer_id
    )

    # if this is not a 200, if will raise and error
    subscription.update(status: :canceled, cancellation_reason: "user_canceled")

    redirect_to dashboard_subscriptions_path, notice: "Lidmaatschap is geannuleerd."
  rescue => e
    Rails.logger.error("[CancelSubscription] Error: #{e.message}")
    redirect_to dashboard_subscriptions_path, alert: "Er is een fout opgetreden bij het annuleren van het lidmaatschap."
  end

  def webhook
    Rails.logger.info("Received webhook for payment #{params[:id]}")
    HandleMollieWebhookJob.perform_later(params[:id])
    head :ok
  end
end
