#!/usr/bin/env ruby

require_relative 'example'
require_relative '../lib/check/metric'

metric_check = Check::Metric.new(
  name: "metric1",
  lower: 5,
  upper: 10,
  positives: 1,
  suspend_after: 1,
  suspend_for: 60
)
metric_check.save

exemplify("Metric check matches")
puts "Default matches: #{metric_check.matches}"
Check.metric(name: "metric1", lower: 4)
puts "Matches after new positive: #{metric_check.matches}"

exemplify("Suspending/unsuspending metric checks")
puts "Now that we had 1 positive matches, is this metric checking suspended? #{metric_check.suspended?}"
puts "New positives will be ignored."
Check.metric(name: "metric1", lower: 3)
puts "Matches after new positive: #{metric_check.matches}"
puts "Metric checking manually unsuspended. #{metric_check.unsuspend!}"
Check.metric(name: "metric1", lower: 2)
puts "Matches after new positive: #{metric_check.matches}"

exemplify("Disabling/enabling metric checks")
puts "Metric checks can be disabled. #{metric_check.disable!}"
puts "New positives will be ignored."
Check.metric(name: "metric1", lower: 1)
puts "Matches after new positive: #{metric_check.matches}"
puts "Metric checking has been enabled. #{metric_check.enable!}"
Check.metric(name: "metric1", lower: 0)
puts "Matches after new positive: #{metric_check.matches}"
