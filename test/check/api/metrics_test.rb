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
          matching_metric = Metric.new(name: "foo").save
          other_metric = Metric.new(name: "bar").save
        end

        it "returns only matching ones" do
          get("/metrics/foo")
          last_response.content_type.must_equal "application/json"
          last_response.status.must_equal 200
          body.size.must_equal 1
          body.first.fetch('name').must_equal "foo"
        end
      end
    end

    describe "POST /metrics" do
      it "returns a 409 if params are invalid" do
        post("/metrics")
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 409
        body["errors"].must_equal({
          'name' => "can't be blank"
        })
      end

      it "creates a new metric if params are valid" do
        post("/metrics/", {name: "metric1"})
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 201
        body.must_equal ["metric1"]
        Metric.find(name: "metric1").must_be :persisted?
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
    end

    describe "DELETE /metrics" do
      it "returns 200 if metric doesn't exist" do
        delete("/metrics", {name: "foo"})
        last_response.status.must_equal 200
      end

      it "deletes a specific metric" do
        Metric.new(name: "foo", lower: 10).save
        Metric.new(name: "foo", lower: 9).save

        delete("/metrics", {name: "foo", lower: 10})
        last_response.content_type.must_equal "application/json"
        last_response.status.must_equal 200
        Metric.find(name: "foo").similar.size.must_equal 1
      end
    end
  end
end