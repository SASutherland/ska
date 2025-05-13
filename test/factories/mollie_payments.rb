FactoryBot.define do
  factory :mollie_payment_response, class: OpenStruct do
    id { "tr_test123" }
    status { "paid" }
    amount { {"value" => "12.99", "currency" => "EUR"} }
    metadata { {"user_id" => user.id} }
    paid_at { Time.current }
    created_at { Time.current }
  end
end
