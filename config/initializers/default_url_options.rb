# config/initializers/default_url_options.rb

host = nil

if Rails.env.development?
  require "net/http"
  require "json"

  begin
    uri = URI("http://localhost:4040/api/tunnels")
    response = Net::HTTP.get(uri)
    tunnels = JSON.parse(response)

    # Find the https tunnel
    public_url = tunnels["tunnels"]
      .find { |t| t["proto"] == "https" }
      .try(:[], "public_url")

    if public_url
      host = URI(public_url).host
      Rails.application.config.x.default_host = host
      puts "[NGROK] Default host set to #{host}"
    else
      puts "[NGROK] No https tunnel found"
    end
  rescue => e
    puts "[NGROK] Error retrieving public URL: #{e.message}"
  end
end

# Fall back if host is still nil
host ||= ENV.fetch("APP_HOST", Rails.env.production? ? "www.ska-leren.com" : "localhost")

protocol = Rails.env.production? ? "https" : "http"
port     = Rails.env.development? && host == "localhost" ? 3000 : nil

defaults = { host:, protocol: }
defaults[:port] = port if port

Rails.application.routes.default_url_options = defaults
ActionMailer::Base.default_url_options = defaults
