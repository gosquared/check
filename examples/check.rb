#!/usr/bin/env ruby

require_relative 'example'
require_relative '../lib/check/metric'

metric_check = Check::Metric.new(
  name: "metric1",
  lower: 5,
  upper: 10,
  matches_for_positive: 2,
  suspend_after_positives: 1,
  suspend_for_seconds: 60
).save

exemplify("Default metric check matches", metric_check.matches.values)

Check.metric(name: "metric1", value: 4)
exemplify("Metric check matches after first match", metric_check.matches.values)
exemplify("Is this metric checking suspended?", metric_check.suspended?)

Check.metric(name: "metric1", value: 3)
exemplify("Metric check matches after second match", metric_check.matches.values)
exemplify("Metric check positives after second match", metric_check.positives.values)
exemplify("Is this metric checking suspended?", metric_check.suspended?)

Check.metric(name: "metric1", value: 2)
exemplify("As the metric check is suspended, new matches will be ignored", metric_check.matches.values)
exemplify("Deleting all positives will unsuspend it", metric_check.delete_positives)

exemplify("Metric checking manually disabled", metric_check.disable!)
Check.metric(name: "metric1", value: 1)
exemplify("As the metric check is disabled, New matches will be ignored", metric_check.matches.values)

exemplify("Metric checking manually enabled", metric_check.enable!)
Check.metric(name: "metric1", value: 0)
exemplify("New matches no longer ignored", metric_check.matches.values)
