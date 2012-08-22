require 'pry'
require 'ap'
require 'turn/autorun'

APP_ROOT = File.expand_path('../../', __FILE__)
$:.push "#{APP_ROOT}/lib"

require_relative 'support/redis'

MiniTest::Unit.after_tests do
  stop_test_redis_server
end
