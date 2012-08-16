require_relative 'example'
require_relative '../lib/check/metric'


metric = Check::Metric.new(:name => "metric1", :lower => 10, :upper => 100, :over_seconds => 120)
metric.save
exemplify("Check::Metric from hash", metric)

metric = Check::Metric.new(:name => "metric1")
metric.lower = 100
metric.upper = 1000
metric.over_seconds = 3600
metric.checks = 1
metric.save
exemplify("Check::Metric from attributes", metric)

exemplify("Similar metrics", metric.similar)

metric.delete
exemplify("Similar metrics after metric.delete", metric.similar)

Check::Metric.delete_all(metric.name)
exemplify("Similar metrics after Metric.delete_all(name)", metric.similar)
