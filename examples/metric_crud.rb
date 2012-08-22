require_relative 'example'
require_relative '../lib/check/metric'

metric_check = Check::Metric.new(name: "metric1", lower: 10, upper: 100, over_seconds: 120).save
exemplify("Check::Metric from hash", metric_check)

metric_check = Check::Metric.new(name: metric_check[:name])
metric_check.lower = 100
metric_check.upper = 1000
metric_check.over_seconds = 3600
metric_check.matches_for_positive = 1
metric_check.save
exemplify("Check::Metric from attributes", metric_check)

exemplify("Creating a new metric with the same name as the existing one will group them together", metric_check.similar)

metric_check.delete
exemplify("Similar metrics after metric.delete", metric_check.similar)

Check::Metric.delete_all(metric_check.name)
exemplify("Similar metrics after Metric.delete_all(name)", metric_check.similar)
