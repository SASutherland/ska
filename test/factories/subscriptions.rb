FactoryBot.define do
  factory :subscription do
    association :user
    association :membership
    mollie_customer_id { "cus_test123" }
    mollie_mandate_id { "mdt_test123" }
    mollie_subscription_id { "sub_test123" }
    status { "active" }
    start_date { Date.today }
    cancellation_reason { nil }
  end
end
