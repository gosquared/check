module Check
  module Config
    REDIS_URI = ENV.fetch('REDIS_URI') { "redis://localhost:6379" }
    REDIS_DB  = ENV.fetch('REDIS_DB') { 0 }.to_i
  end
end
