require_relative 'test_helper'

require 'check'

describe Check do
  it "configures Redis connection" do
    config_uri = URI(ENV['CHECK_REDIS_URI'])
    Redis.current.client.host.must_equal config_uri.host
    Redis.current.client.port.must_equal config_uri.port
    Redis.current.client.path.to_s.must_equal config_uri.path
  end
end
