# Configure SSL for Postmark API client
# This fixes SSL certificate verification issues, particularly CRL (Certificate Revocation List) errors
# 
# Common solutions:
# 1. Update system certificates: brew install ca-certificates (macOS)
# 2. Update OpenSSL: gem update openssl
# 3. This patch allows CRL verification failures in development only

if Rails.env.development?
  require 'openssl'
  require 'net/http'
  
  # Patch OpenSSL::SSL::SSLContext to always set verify callback that allows CRL failures
  module PostmarkSSLContextFix
    def initialize(*args)
      super(*args)
      # Override verify callback after initialization
      original_verify_callback = @verify_callback
      @verify_callback = lambda do |preverify_ok, store_context|
        # In development, don't fail on CRL errors
        if !preverify_ok && store_context
          error_code = store_context.error
          if error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL || 
             error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL_ISSUER
            Rails.logger.warn "SSL: CRL check failed but allowing in development: #{store_context.error_string} (#{error_code})"
            return true
          end
        end
        # Call original callback if it exists, otherwise use preverify_ok
        if original_verify_callback
          original_verify_callback.call(preverify_ok, store_context)
        else
          preverify_ok
        end
      end
    end
  end
  
  # Apply the patch to OpenSSL::SSL::SSLContext
  OpenSSL::SSL::SSLContext.prepend(PostmarkSSLContextFix) if Rails.env.development?
  
  # Also patch Net::HTTP to ensure verify callback is set
  module PostmarkHTTPFix
    def use_ssl=(flag)
      result = super
      if flag
        # Ensure ssl_context exists
        @ssl_context ||= OpenSSL::SSL::SSLContext.new
        
        # Set verify callback if not already set
        unless @ssl_context.verify_callback
          @ssl_context.verify_callback = lambda do |preverify_ok, store_context|
            if !preverify_ok && store_context
              error_code = store_context.error
              if error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL || 
                 error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL_ISSUER
                Rails.logger.warn "SSL: CRL check failed but allowing in development: #{store_context.error_string} (#{error_code})"
                return true
              end
            end
            preverify_ok
          end
        end
      end
      result
    end
    
    # Also patch start method to ensure SSL context is configured
    def start
      if @ssl_context
        # Ensure verify callback is set
        unless @ssl_context.verify_callback
          @ssl_context.verify_callback = lambda do |preverify_ok, store_context|
            if !preverify_ok && store_context
              error_code = store_context.error
              if error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL || 
                 error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL_ISSUER
                Rails.logger.warn "SSL: CRL check failed but allowing in development: #{store_context.error_string} (#{error_code})"
                return true
              end
            end
            preverify_ok
          end
        end
      end
      super
    end
  end
  
  Net::HTTP.prepend(PostmarkHTTPFix) if Rails.env.development?
  
  # Also patch the connect method to ensure callback is set at connection time
  module PostmarkHTTPConnectFix
    def connect
      if @use_ssl && @ssl_context
        # Force set verify callback right before connection (override any existing)
        @ssl_context.verify_callback = lambda do |preverify_ok, store_context|
          if !preverify_ok && store_context
            error_code = store_context.error
            # Handle CRL-related errors
            if error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL || 
               error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL_ISSUER ||
               error_code == 3  # V_ERR_UNABLE_TO_GET_CRL constant value
              Rails.logger.warn "SSL: CRL check failed but allowing in development: #{store_context.error_string} (#{error_code})"
              return true
            end
          end
          preverify_ok
        end
      end
      super
    end
  end
  
  Net::HTTP.prepend(PostmarkHTTPConnectFix) if Rails.env.development?
  
  # As a last resort, patch Net::HTTP#do_start which is called before connect
  module PostmarkHTTPDoStartFix
    def do_start
      if @use_ssl
        @ssl_context ||= OpenSSL::SSL::SSLContext.new
        # Always set the verify callback before starting
        @ssl_context.verify_callback = lambda do |preverify_ok, store_context|
          if !preverify_ok && store_context
            error_code = store_context.error
            if error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL || 
               error_code == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL_ISSUER ||
               error_code == 3
              Rails.logger.warn "SSL: CRL check failed but allowing in development: #{store_context.error_string} (#{error_code})"
              return true
            end
          end
          preverify_ok
        end
      end
      super
    end
  end
  
  Net::HTTP.prepend(PostmarkHTTPDoStartFix) if Rails.env.development?
end

