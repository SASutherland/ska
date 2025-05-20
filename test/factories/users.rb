FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    password { "password" }
    role { 0 }
    first_name { "John" }
    last_name { "Doe" }
    mollie_customer_id { "cus_test123" }
  end
end
