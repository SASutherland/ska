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
      Rails.application.config.x.default_host = URI(public_url).host
      puts "[NGROK] Default host set to #{Rails.application.config.x.default_host}"
    else
      puts "[NGROK] No https tunnel found"
    end
  rescue => e
    puts "[NGROK] Error retrieving public URL: #{e.message}"
  end
end
