Pythy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Normally this is set to true in development, which would cause the Rails
  # default exception trace pages to show up when errors occur. Since we have
  # created our own error pages, we want to see those in development as well.
  config.consider_all_requests_local = false

  # Disable caching
  config.action_controller.perform_caching = false

  config.action_mailer.default_url_options = { host: '127.0.0.1', port: 3000 }

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false

#  config.log_level = :info
  config.log_formatter = proc do |severity, datetime, progname, msg|
    if severity == 'DEBUG' && msg.blank?
      ''
    else
      case severity
      when 'DEBUG'
        severity_colored = "\033[36;40m[DEBUG]\033[0m" # cyan
      when 'INFO'
        severity_colored = "\033[32;40m[INFO]\033[0m" # green
      when 'WARN'
        severity_colored = "\033[35;40m[WARNING]\033[0m" # magenta
      when 'ERROR'
        severity_colored = "\033[31;40m[ERROR]\033[0m" # red
      when 'FATAL'
        severity_colored = "\033[7;31;40m[FATAL]\033[0m" # black, red bg
      else
        severity_colored = "[#{severity}]" # none
      end
      "%s %s %s\n" % [
        datetime.strftime('%Y-%m-%d %H:%M:%S'),
        severity_colored,
        String === msg ? msg : msg.inspect
        ]
    end
  end
end
