require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module BugBountyApi
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.time_zone = "UTC"
    config.active_job.queue_adapter = :sidekiq
    config.autoload_paths << Rails.root.join("app/services")
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
