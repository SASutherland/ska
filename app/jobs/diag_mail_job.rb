class DiagMailJob < ApplicationJob
  queue_as :default
  def perform
    dm  = ActionMailer::Base.delivery_method
    pm  = ActionMailer::Base.postmark_settings
    tok = ENV['POSTMARK_API_TOKEN'].present?
    from = ApplicationMailer.default_params[:from]
    stream = (ApplicationMailer.default_params['X-PM-Message-Stream'] ||
              ApplicationMailer.default_params[:message_stream])

    Rails.logger.info "MAIL DIAG dm=#{dm.inspect} token?=#{tok} from=#{from.inspect} stream=#{stream.inspect} pm=#{pm.inspect}"
  end
end
