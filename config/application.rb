require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ska
  class Application < Rails::Application
    config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.

    # Set default locale to Dutch
    config.i18n.default_locale = :nl
    config.i18n.available_locales = [:nl, :en]

    # Fallback to English for missing translations in Dutch
    config.i18n.fallbacks = [:en]

    config.active_job.queue_adapter = :sidekiq

    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Amsterdam"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
