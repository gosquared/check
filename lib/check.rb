require 'bundler/setup'
require 'redis'

require_relative 'check/version'
require_relative 'check/config'

module Check
  Redis.current = Redis.new(
    :url    => Check::Config::REDIS_URI,
    :db     => Check::Config::REDIS_DB,
    :driver => :hiredis
  )
end
