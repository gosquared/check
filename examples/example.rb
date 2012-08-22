#!/usr/bin/env ruby

require 'bundler/setup'
require 'awesome_print'
require 'pry'

require_relative '../test/support/redis'

def exemplify(description, object)
  puts "\n::: #{description} ".ljust(70, ":::")
  ap(object, indent: -2)
end

at_exit { stop_test_redis_server }
