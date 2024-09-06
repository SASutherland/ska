class UserMailer < ApplicationMailer
  default from: 'support@yourdomain.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://yourdomain.com/login'
    mail(to: @user.email, subject: 'Welcome to Stichting Kansen Academie!')
  end
end
