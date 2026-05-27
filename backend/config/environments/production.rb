require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.active_storage.service = :local
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.action_cable.url = ENV.fetch("ACTION_CABLE_URL", "wss://api.example.com/cable")
  config.action_cable.allowed_request_origins = ENV.fetch("CORS_ORIGINS", "").split(",")
  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"
end
