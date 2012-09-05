require_relative '../test_helper'

require 'check/metric'

module Check
  describe Metric do
    before do
      Redis.current.flushdb
    end

    describe "name" do
      it "must be present" do
        Metric.new.wont_be :valid_name?
        Metric.new(name: "foo").must_be :valid_name?
      end

      it "cannot be empty string" do
        Metric.new(name: " ").wont_be :valid_name?
      end
    end

    it "accepts custom attributes" do
      emails = %w[foo@bar.com foo2@bar.com]
      metric = Metric.new(name: "foo", email: emails)
      metric[:email].must_equal emails
    end

    describe "#save" do
      it "doesn't create duplicates" do
        Metric.new(name: "foo", lower: 1).save
        2.times { Metric.new(name: "foo", lower: 1).save }
        Redis.current.keys.size.must_equal 1
        Metric.find(name: "foo").similar.size.must_equal 1
      end

      it "updating a metric saves it as a new one" do
        metric = Metric.new(name: "foo").save
        metric.similar.size.must_equal 1
        metric.lower = 5
        metric.save
        metric.similar.size.must_equal 2
      end

      it "updating a metric name saves it as a new one" do
        metric = Metric.new(name: "foo").save
        metric.name = "bar"
        metric.save
        Redis.current.keys.must_equal %w[foo bar]
      end
    end

    describe "#similar" do
      it "returns all metric checks with the same name" do
        Metric.new(name: "foo", lower: 1).save
        metric = Metric.new(name: "foo", lower: 10)
        metric.similar.map(&:lower).must_equal [1]
        metric.save
        (metric.similar.map(&:lower) - [1, 10]).must_equal []
      end
    end

    describe "#notify?" do
      it "disabled if REDIS_NOTIFICATIONS is an empty string" do
        ENV['CHECK_REDIS_NOTIFICATIONS'] = ""
        load 'check.rb' # pardon the shouty CONSTANTS...
        Metric.new(name: "foo").wont_be :notify?
      end
    end

    describe "#check" do
      before do
        @metric = Metric.new(
          name: "foo",
          lower: 5,
          upper: 10,
          matches_for_positive: 2,
          over_seconds: 60,
          suspend_after_positives: 1,
          suspend_for_seconds: 2
        ).save
      end

      it "stores matches" do
        @metric.matches.length.must_equal 0
        @metric.check({name: "foo", value: 4})
        @metric.matches.length.must_equal 1
      end

      it "matches don't grow past matches_for_positive" do
        3.times { |value| @metric.check({name: "foo", value: value}) }
        @metric.matches.length.must_be :<=, @metric[:matches_for_positive]
      end

      describe "when values are between lower & upper bounds" do
        it "no matches get recorded" do
          (5..10).each { |value| @metric.check({name: "foo", value: value}) }
          @metric.matches.length.must_equal 0
        end
      end

      describe "when values are outside lower & upper bounds" do
        describe "when new matches are within over_seconds period" do
          before do
            #binding.pry
            # $ redis-cli -s /tmp/redis-check-test.sock subscribe check_notifications
            (10..13).each { |value| @metric.check({name: "foo", value: value}) }
          end

          it "a new positive gets created" do
            @metric.positives.length.must_equal 1
          end

          it "and matching gets suspended for :suspend_for_seconds" do
            @metric.must_be :suspended?
            @metric.matches.length.must_equal 0
          end

          # Check the before for tips on a quick, manual test
          it "sends pub/sub notification"
        end
      end

      describe "multiple metric checks" do
        it "checks against all persisted checks" do
          metric = Metric.new(
            name: "foo",
            lower: 1,
            matches_for_positive: 1
          ).save
          metric.check({name: "foo", value: 0})
          metric.matches.length.must_equal 0
          metric.positives.length.must_equal 1
          @metric.matches.length.must_equal 1
          @metric.positives.length.must_equal 0
        end
      end
    end

    describe "disable/enable" do
      before do
        @metric = Metric.new(
          name: "foo",
          lower: 5
        ).save
      end

      describe "by default" do
        it "is not disabled" do
          @metric.wont_be :disabled?
        end

        it "matches are not ignored" do
          @metric.check({name: "foo", value: 1})
          @metric.matches.length.must_equal 1
        end
      end

      describe "when it is disabled" do
        it "new matches are ignored" do
          @metric.disable!
          @metric.must_be :disabled?
          @metric.check({name: "foo", value: 1})
          @metric.matches.length.must_equal 0
          @metric.enable!
          @metric.wont_be :disabled?
        end
      end
    end

    describe "#delete" do
      before do
        @metric = Metric.new(name: "foo", lower: 2).save
      end

      it "deletes itself from the metric checks with the same name" do
        metric = Metric.new(name: "foo", lower: 1).save
        metric.must_be :persisted?
        metric.delete
        metric.wont_be :persisted?
        metric.similar.must_equal [@metric.to_hash]
      end

      it "deletes all matches" do
        @metric.check({name: "foo", value: 1})
        Redis.current.must_be :exists, @metric.matches_key
        @metric.delete
        Redis.current.wont_be :exists, @metric.matches_key
      end

      it "deletes all positives" do
        2.times { |value| @metric.check({name: "foo", value: value}) }
        Redis.current.must_be :exists, @metric.positives_key
        @metric.delete
        Redis.current.wont_be :exists, @metric.positives_key
      end

      it "deletes disable" do
        @metric.disable!
        @metric.delete
        Redis.current.wont_be :exists, @metric.disable_key
      end
    end

    describe ".defaults" do
      it "overwrite default values" do
        Metric.new.must_equal Metric.defaults
        Metric.defaults = { foo: "bar"}
        metric = Metric.new
        metric.fetch(:foo).must_equal "bar"
        metric.first.must_equal Metric.defaults.first
      end
    end

    describe ".find" do
      it "behaves like new" do
        Metric.find.must_equal Metric.new
      end

      it "doesn't create duplicates" do
        Metric.new(name: "foo").save
        metric = Metric.find(name: "foo")
        metric.similar.size.must_equal 1
      end
    end

    describe ".delete_all" do
      it "deletes all metric checks" do
        Metric.new(name: "foo", lower: 1).save
        Metric.new(name: "foo", lower: 2).save

        Metric.delete_all("foo")
        Metric.new(name: "foo").similar.size.must_equal 0
      end
    end
  end
end
