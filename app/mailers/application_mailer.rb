class ApplicationMailer < ActionMailer::Base
  default from: "support@ska-leren.com",
          message_stream: "outbound",
          track_opens: true
  
  layout false
end


# require 'postmark' 
# client = Postmark::ApiClient.new(Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :api_token)) 
# resp = client.deliver_with_template( 
#   from: "no-reply@ska-leren.com", 
#   to: "test@blackhole.postmarkapp.com",
#   template_id: "40627687",
#   message_stream: "outbound",
#   template_model: {
#     name: user.first_name,
#     sender_name: "Nour el Ghezaoui",
#     product_name: "Stichting Kansen Academie",
#     trial_days: 3,
#     support_email: 'support@ska-leren.com',
#     action_url: "http://2c0b650d1924.ngrok-free.app/"
#   }
# ) 
# puts resp.inspect