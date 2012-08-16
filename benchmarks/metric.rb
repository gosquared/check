#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark/ips'
require 'pry'

require_relative '../test/support/redis'
start_test_redis_server

require_relative '../lib/check/metric'

Benchmark.ips(1) do |x|
  x.report("Create") do
    i = 0
    Check::Metric.new(
      :name         => "metric#{i}",
      :lower        => 10,
      :upper        => 100,
      :over_seconds => 120
    ).save
    i += 1
  end

  x.report("Update") do
    i = 1
    Check::Metric.new(
      :name         => "metric",
      :lower        => 10*i,
      :upper        => 100*i,
      :over_seconds => 120
    ).save
    i += 1
  end
end

stop_test_redis_server
