require 'pry'
require 'turn/autorun'

APP_ROOT = File.expand_path('../../', __FILE__)
$:.push "#{APP_ROOT}/lib"

require_relative 'support/redis'
start_test_redis_server

MiniTest::Unit.after_tests do
  stop_test_redis_server
end
