Pc::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  Paperclip.options[:command_path] = "DYLD_LIBRARY_PATH='/usr/local/Cellar/imagemagick/6.6.3-9/lib' /usr/local/Cellar/imagemagick/6.6.3-9/bin"
end
