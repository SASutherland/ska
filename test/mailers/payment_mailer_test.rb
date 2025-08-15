require "test_helper"

class PaymentMailerTest < ActionMailer::TestCase
  test "payment_success" do
    payment = create(:payment, user: user)
    email = PaymentMailer.payment_success(payment)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["no-reply@ska-leren.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Je betaling is geslaagd", email.subject
    assert_includes email.body.to_s, "Je betaling is succesvol ontvangen"
  end

  test "payment_failed" do
    user = create(:user)
    reason = "failed"
    email = PaymentMailer.payment_failed(user, reason)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["no-reply@ska-leren.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Je betaling is mislukt", email.subject
    assert_includes email.body.to_s, "reden: #{reason}"
  end
end
