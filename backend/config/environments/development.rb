require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_storage.service = :local
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.allowed_request_origins = [/http:\/\/localhost.*/]
end
