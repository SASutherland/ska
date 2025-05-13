FactoryBot.define do
  factory :membership do
    name { "Docenten plan" }
    price { 12.99 }
    interval { "month" }
  end
end
