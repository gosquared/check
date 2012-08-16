require_relative '../test_helper'

require 'check/metric'

module Check
  describe Metric do
    before do
      Redis.current.flushdb
    end

    it "must have a name" do
      Metric.new.wont_have :valid_name?
    end

    it "defaults can be overwritten" do
      Metric.new.must_equal Metric::DEFAULTS
      Metric.defaults = { foo: "bar"}
      Metric.new.must_equal({ foo: "bar" })
      # Don't forget to reset this back...
      Metric.defaults = Metric::DEFAULTS
    end

    it "accepts custom attributes" do
      emails = %w[foo@bar.com foo2@bar.com]
      metric = Metric.new(name: "foo", email: emails)
      metric[:email].must_equal emails
    end

    it "doesn't create duplicates" do
      Metric.new(name: "foo", lower: 1).save
      metric = Metric.new(name: "foo", lower: 1)
      metric.save
      metric.similar.map(&:lower).must_equal [1]
    end

    it "updating a metric saves it as a new one" do
      metric = Metric.new(name: "foo")
      metric.save
      metric.similar.map(&:lower).must_equal [Metric::DEFAULTS[:lower]]
      metric.lower = 5
      metric.save
      (metric.similar.map(&:lower) - [1, 5]).must_equal []
    end

    it "groups similar" do
      Metric.new(name: "foo", lower: 1).save
      metric = Metric.new(name: "foo", lower: 10)
      metric.similar.map(&:lower).must_equal [1]
      metric.save
      (metric.similar.map(&:lower) - [1, 10]).must_equal []
    end

    it "deletes one" do
      Metric.new(name: "foo", lower: 2).save
      metric = Metric.new(name: "foo", lower: 1)
      metric.save
      metric.must_be :persisted?
      metric.delete
      metric.wont_be :persisted?
      metric.similar.map(&:lower).must_equal [2]
    end

    it "deletes all" do
      Metric.new(name: "foo", lower: 1).save
      Metric.new(name: "foo", lower: 2).save

      Metric.delete_all("foo")
      Metric.new(name: "foo").similar.size.must_equal 0
    end
  end
end
