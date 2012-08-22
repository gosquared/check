#!/usr/bin/env ruby

require_relative 'benchmark'
require_relative '../lib/check/metric'

metric1 = Check::Metric.new(
  name: "metric1",
  lower: 5,
  matches_for_positive: 1000,
  suspend_after_positives: 10
).save

metric2 = Check::Metric.new(
  name: "metric2",
  lower: 5,
  matches_for_positive: 10,
  suspend_after_positives: 2
).save

metric3 = Check::Metric.new(
  name: "metric3"
).save
metric3.disable!

below_lower = (0..4).to_a

Benchmark.ips(1) do |x|
  x.report("Check always") do
    Check::Metric.find(name: "metric1").check(
      value: below_lower.sample
    )
  end

  x.report("Check suspended") do
    Check::Metric.find(name: "metric2").check(
      value: below_lower.sample
    )
  end

  x.report("Check disabled") do
    Check::Metric.find(name: "metric3").check(
      value: below_lower.sample
    )
  end

  x.report("Check inexistent") do
    Check::Metric.find(name: "metric4").check(
      value: below_lower.sample
    )
  end
end
