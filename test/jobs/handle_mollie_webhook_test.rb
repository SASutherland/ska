# test/jobs/handle_mollie_webhook_test.rb
require "test_helper"
require "minitest/mock"

class HandleMollieWebhookTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  def capture_logs
    original_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)
    yield
    log_output.string
  ensure
    Rails.logger = original_logger
  end

  def setup
    @user = create(:user)
    @subscription = create(:subscription, user: @user, status: :active, mollie_subscription_id: "sub_test123", mollie_customer_id: "cus_test123")
    @payment_id = "tr_test123"
  end

  def mollie_payment(status, metadata = {user_id: @user.id})
    OpenStruct.new(
      id: @payment_id,
      paid?: status == "paid",
      description: "Test Payment",
      status: status,
      metadata: metadata,
      amount: OpenStruct.new(value: "12.99", currency: "EUR"),
      paid_at: Time.current
    )
  end

  test "marks the subscription as active when payment is successful" do
    payment = mollie_payment("paid")
    subscription = FactoryBot.create(:subscription, status: "pending", user: @user)

    Mollie::Payment.stub(:get, payment) do
      @user.stub(:active_subscription, subscription) do
        User.stub(:find_by, @user) do
          HandleMollieWebhook.new(@payment_id).call
        end
      end
    end

    subscription.reload
    assert_equal "active", subscription.status
    assert_nil subscription.cancellation_reason
  end

  test 'marks the subscription as canceled with the reason "failed" when payment fails' do
    payment = mollie_payment("failed")

    Mollie::Payment.stub(:get, ->(id) { payment }) do
      assert_changes "@subscription.reload.status", to: "canceled" do
        assert_changes "@subscription.reload.cancellation_reason", to: "failed" do
          HandleMollieWebhook.new(@payment_id).call
        end
      end
    end
  end

  test 'marks the subscription as canceled with the reason "canceled" when payment is canceled' do
    payment = mollie_payment("canceled")

    Mollie::Payment.stub(:get, ->(id) { payment }) do
      assert_changes "@subscription.reload.status", to: "canceled" do
        assert_changes "@subscription.reload.cancellation_reason", to: "canceled" do
          HandleMollieWebhook.new(@payment_id).call
        end
      end
    end
  end

  test "does not update the subscription status when payment status is unhandled" do
    payment = mollie_payment("pending")

    Mollie::Payment.stub(:get, ->(id) { payment }) do
      assert_no_changes "@subscription.reload.status" do
        HandleMollieWebhook.new(@payment_id).call
      end
    end
  end

  test "logs that no metadata or user ID was found and skips when no user is found in metadata" do
    payment = mollie_payment("paid", {}) # empty metadata

    log_output = capture_logs do
      Mollie::Payment.stub(:get, ->(id) { payment }) do
        HandleMollieWebhook.new(@payment_id).call
      end
    end

    assert_includes log_output, "[HandleMollieWebhook] No metadata or missing user_id, skipping"
  end

  test "logs that the user was not found and skips when no user is found" do
    payment = mollie_payment("paid", {user_id: 9999}) # non-existent user

    log_output = capture_logs do
      Mollie::Payment.stub(:get, ->(id) { payment }) do
        HandleMollieWebhook.new(@payment_id).call
      end
    end

    assert_includes log_output, "[HandleMollieWebhook] User not found with ID 9999, skipping"
  end

  test "logs that no active subscription was found and skips when no subscription is found" do
    payment = mollie_payment("paid")

    log_output = capture_logs do
      @user.stub(:active_subscription, nil) do
        User.stub(:find_by, @user) do
          Mollie::Payment.stub(:get, ->(id) { payment }) do
            HandleMollieWebhook.new(@payment_id).call
          end
        end
      end
    end

    assert_includes log_output, "[HandleMollieWebhook] No active subscription found for user #{@user.id}, skipping"
  end

  test "sends success email when payment is successful" do
    payment = mollie_payment("paid", {user_id: @user.id})

    Mollie::Payment.stub(:get, ->(id) { payment }) do
      assert_enqueued_emails 1 do
        HandleMollieWebhook.new("dummy_id").call
      end
    end

    clear_enqueued_jobs
  end

  test "sends failure email when payment failed" do
    payment = mollie_payment("failed", {user_id: @user.id})

    Mollie::Payment.stub(:get, ->(id) { payment }) do
      assert_enqueued_emails 1 do
        HandleMollieWebhook.new("dummy_id").call
      end
    end

    clear_enqueued_jobs
  end
end
