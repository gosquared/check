require_relative '../../test_helper'

require 'check/api/metrics'

module Check
  describe Metrics do
    include Rack::Test::Methods

    def app
      Check::Metrics
    end

    def body
      JSON.parse(last_response.body)
    end

    before do
      Redis.current.flushdb
    end

    describe "GET /metrics/:metric_name" do
      describe "when there are no metrics" do
        it "returns empty array" do
          get("/metrics/foo")
          last_response.content_type.must_equal "application/json"
          last_response.status.must_equal 200
          body.must_equal([])
        end
      end

      describe "when there are metrics" do
        before do
          Metric.new(name: "foo").save
          Metric.new(name: "bar").save
        end

        it "returns only matching ones" do
          get("/metrics/foo")
          last_response.content_type.must_equal "application/json"
          last_response.status.must_equal 200
          body.size.must_equal 1
          body.first.fetch('name').must_equal "foo"
        end
      end

      describe "when there are metrics with url-safe characters in their name" do
        before do
          Metric.new(name: "foo-bar_baz.qux").save
          Metric.new(name: "foo.qux").save
        end

        it "returns only matching ones" do
          get("/metric", :name => "foo-bar_baz.qux")
          last_response.content_type.must_equal "application/json"
          last_response.status.must_equal 200
          body.size.must_equal 1
          body.first.fetch('name').must_equal "foo-bar_baz.qux"
        end
      end
    end

    describe "POST /metrics" do
      it "returns a 400 if params are invalid" do
        post("/metrics")
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 400
      end

      it "creates a new metric if params are valid" do
        post("/metrics/", { name: "metric1" })
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 201
        body.must_equal ["metric1"]
        Metric.find(name: "metric1").must_be :persisted?
      end

      it "persists values with , as arrays" do
        post("/metrics", { name: "metric2", emails: "foo@bar.com,baz@qux.com" })
        metric = Metric.find(name: "metric2").similar.first
        (%w[foo@bar.com baz@qux.com] - metric.emails).must_equal []
      end
    end

    describe "DELETE /metrics/:metric_name" do
      describe "when metric does not exist" do
        it "doesn't delete anything" do
          delete("/metrics/foo")
          last_response.status.must_equal 200
        end
      end

      describe "when metric exists" do
        it "deletes all similar" do
          Metric.new(name: "foo").save
          Metric.new(name: "foo", lower: 2).save
          Metric.new(name: "bar").save
          delete("/metrics/foo")
          last_response.status.must_equal 200
          Redis.current.keys.must_equal ["bar"]
        end
      end

      describe "when metric has url-safe name" do
        it "deletes all similar" do
          Metric.new(name: "foo-bar_baz.qux").save
          Metric.new(name: "foo.bar").save
          delete("/metric", :name => "foo.bar")
          last_response.status.must_equal 200
          Redis.current.keys.must_equal ["foo-bar_baz.qux"]
        end
      end
    end

    describe "DELETE /metrics" do
      it "returns 200 if metric doesn't exist" do
        delete("/metrics", { name: "foo" })
        last_response.status.must_equal 200
      end

      it "deletes a specific metric" do
        Metric.new(name: "foo", lower: 10).save
        Metric.new(name: "foo", lower: 9).save

        delete("/metrics", { name: "foo", lower: 10 })
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 200
        Metric.find(name: "foo").similar.size.must_equal 1
      end
    end
  end
end
