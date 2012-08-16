#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark/ips'
require 'pry'

require_relative '../test/support/redis'

at_exit { stop_test_redis_server }
