Mollie::Client.configure do |config|
  config.api_key = Rails.application.credentials.dig(Rails.env.to_sym, :mollie, :api_key)
end
