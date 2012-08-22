#!/usr/bin/env ruby

require_relative 'benchmark'
require_relative '../lib/check/metric'

range = (1..10000).to_a
10000.times do |i|
  Check::Metric.new(name: "metric-#{i}", lower: i).save
  Check::Metric.new(name: "metric-delete", lower: range.sample).save
end

Benchmark.ips(1) do |x|
  x.report("Create unique") do
    i = 0
    Check::Metric.new(
      name:          "metric#{i}",
      lower:         10,
      upper:         100,
      over_seconds:  120
    ).save
    i += 1
  end

  x.report("Create similar") do
    i = 0
    Check::Metric.new(
      name:          "metric",
      lower:         10,
      upper:         100,
      over_seconds:  120
    ).save
    i += 1
  end

  x.report("Delete unique") do
    Check::Metric.new(name: "metric-delete", lower: range.sample).delete
  end

  x.report("Delete similar") do
    sample = range.sample
    Check::Metric.new(name: "metric-#{sample}", lower: sample).delete
  end
end
