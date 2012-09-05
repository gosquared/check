#!/usr/bin/env ruby

require_relative 'example'
require_relative '../lib/check/metric'

metric = Check::Metric.new(
  name: "metric1",
  lower: 5,
  upper: 10,
  matches_for_positive: 2,
  suspend_after_positives: 1,
  suspend_for_seconds: 60
).save

exemplify("Default metric check matches", metric.matches.values)

metric.check(value: 4)
exemplify("Metric check matches after first match", metric.matches.values)
exemplify("Is this metric checking suspended?", metric.suspended?)

metric.check(value: 3)
exemplify("Metric check matches after second match", metric.matches.values)
exemplify("Metric check positives after second match", metric.positives.values)
exemplify("Is this metric checking suspended?", metric.suspended?)

metric.check(value: 2)
exemplify("As the metric check is suspended, new matches will be ignored", metric.matches.values)
exemplify("Deleting all positives will unsuspend it", metric.delete_positives)

exemplify("Metric checking manually disabled", metric.disable!)
metric.check(value: 1)
exemplify("As the metric check is disabled, new matches will be ignored", metric.matches.values)

exemplify("Metric checking manually enabled", metric.enable!)
metric.check(value: 0)
exemplify("New matches no longer ignored", metric.matches.values)
