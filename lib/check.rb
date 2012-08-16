require 'bundler/setup'
require 'redis'

require_relative 'check/version'

module Check
  extend self

  # this can be either redis:// or unix://
  REDIS_URI = ENV.fetch('REDIS_URI') { "redis://localhost:6379" }
  REDIS_DB  = ENV.fetch('REDIS_DB') { 0 }.to_i

  Redis.current = Redis.new(
    url:     Check::REDIS_URI,
    db:      Check::REDIS_DB,
    driver:  :hiredis
  )

  def metric
    # metric checking...
  end
end
