require "postmark-rails/templated_mailer"

class TrialMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def trial_limit_reached(user)
    @user = user

    self.template_model = {
      name:         @user.first_name,
      sender_name:  "Nour el Ghezaoui",
      product_name: "Stichting Kansen Academie",
      action_url:   dashboard_subscriptions_url
    }

    mail to: user.email, postmark_template_alias: "trial_expired"
  end
end