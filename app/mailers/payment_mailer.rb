class PaymentMailer < ApplicationMailer
  default from: "no-reply@ska-leren.com"

  def payment_success(user)
    @user = user
    mail(to: @user.email, subject: "Je betaling is geslaagd")
  end

  def payment_failed(user, reason)
    @user = user
    @reason = reason
    mail(to: @user.email, subject: "Je betaling is mislukt")
  end
end
