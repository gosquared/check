require 'bundler/setup'
require 'redis'

require_relative 'check/version'

module Check
  REDIS_URI = ENV.fetch('REDIS_URI') { "redis://localhost:6379" }
  REDIS_DB  = ENV.fetch('REDIS_DB') { 0 }.to_i

  METRIC_DEFAULTS = {
    lower:                  0,
    upper:                  0,
    checks:                 1,
    over_seconds:           60,
    suspend_after_matches:  5,
    suspend_for:            600
  }

  def self.metric_defaults
    if block_given?
      yield
    else
      METRIC_DEFAULTS
    end
  end

  Redis.current = Redis.new(
    :url    => Check::REDIS_URI,
    :db     => Check::REDIS_DB,
    :driver => :hiredis
  )
end
