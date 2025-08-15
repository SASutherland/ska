require "postmark-rails/templated_mailer"
require "money-rails/helpers/action_view_extension"

class PaymentMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin
  # Make the helper available in templates:
  # helper  MoneyRails::ActionViewExtension
  # And inside this class (so you can call it in template_model):
  include MoneyRails::ActionViewExtension

  def payment_failed(user, reason)
    @user = user
    @reason = reason

    self.template_model = {
      name:         @user.first_name,
      sender_name:  "Nour el Ghezaoui",
      product_name: "Stichting Kansen Academie",
      support_email: 'support@ska-leren.com',
      action_url:   dashboard_subscriptions_url
    }

    mail to: @user.email, postmark_template_alias: "payment_failed"
  end

  def payment_success(payment)
    @payment = payment
    @user = @payment.user

    self.template_model = {
      name:         @user.first_name,
      product_name: "Stichting Kansen Academie",
      payment_public_id: @payment.public_id,
      payment_date: @payment.paid_at.to_date,
      payment_amount: humanized_money_with_symbol(@payment.amount),
      total_amount: humanized_money_with_symbol(@payment.amount),
      payment_description: @payment.description,
      support_email: 'support@ska-leren.com',
      action_url:   dashboard_subscriptions_url
    }

    mail to: @user.email, postmark_template_alias: "receipt"
  end
end
