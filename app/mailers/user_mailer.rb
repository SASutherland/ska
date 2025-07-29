class UserMailer < ApplicationMailer
  default from: 'support@ska-lerencom'

  def welcome_email(user)
    @user = user
    @url  = 'http://www.ska-leren.com/'
    mail(to: @user.email, subject: 'Welcome to Stichting Kansen Academie!')
  end
end
