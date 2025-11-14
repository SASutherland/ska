require "postmark-rails/templated_mailer"

class AdminMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def new_signup_request(user)
    @user = user
    admin_emails = User.admins.pluck(:email)

    return if admin_emails.empty?

    self.template_model = {
      user_name: @user.full_name,
      user_email: @user.read_attribute(:email),
      user_first_name: @user.first_name,
      user_last_name: @user.last_name,
      signup_date: @user.created_at.strftime("%d-%m-%Y om %H:%M"),
      admin_url: Rails.application.routes.url_helpers.dashboard_manage_users_url
    }

    mail to: admin_emails, postmark_template_alias: "new_signup_request"
  end
end

