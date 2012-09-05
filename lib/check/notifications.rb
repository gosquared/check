require_relative '../check'

require 'msgpack'

module Check
  class Notifications
    def initialize(redis_notifications=REDIS_NOTIFICATIONS)
      Redis.current.subscribe(redis_notifications) do |on|
        if block_given?
          yield(on)
        else
          on_subscribe.(on)
          on_message.(on)
          on_unsubscribe.(on)
        end
      end
    end

    def on_subscribe
      Proc.new do |on|
        on.subscribe do |channel, subscriptions|
          puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
        end
      end
    end

    def on_message
      Proc.new do |on|
        on.message do |channel, message|
          puts "#{channel}: #{MessagePack.unpack(message)}"
        end
      end
    end

    def on_unsubscribe
      Proc.new do |on|
        on.unsubscribe do |channel, subscriptions|
          puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
        end
      end
    end
  end
end
