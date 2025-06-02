FactoryBot.define do
  factory :payment do
    mollie_id { "MyString" }
    user { nil }
    subscription { nil }
    amount_cents { 1 }
    amount_currency { "MyString" }
    status { "MyString" }
    description { "MyString" }
    paid_at { "2025-05-29 09:21:29" }
  end
end
