class ApplicationMailer < ActionMailer::Base
  default from: "support@ska-leren.com",
          message_stream: "outbound",
          track_opens: true
  
  layout false
end