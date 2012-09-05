require 'bundler/setup'
require 'redis'

require_relative 'check/version'

module Check
  extend self

  # Can be either redis:// or unix://
  REDIS_URI = ENV.fetch('CHECK_REDIS_URI') { "redis://localhost:6379" }
  REDIS_DB  = ENV.fetch('CHECK_REDIS_DB') { 0 }.to_i
  REDIS_NOTIFICATIONS = ENV.fetch('CHECK_REDIS_NOTIFICATIONS') { "check_notifications" }

  Redis.current = Redis.new(
    url:     Check::REDIS_URI,
    db:      Check::REDIS_DB,
    driver:  :hiredis
  )
end
