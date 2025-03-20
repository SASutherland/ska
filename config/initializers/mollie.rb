Mollie::Client.configure do |config|
  config.api_key = Rails.application.credentials.dig(:mollie, :api_key)
end
