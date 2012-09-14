require_relative '../check'

require 'msgpack'

module Check
  class Notifications
    def initialize(redis_notifications=REDIS_NOTIFICATIONS)
      shutdown_gracefully

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
          puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
        end
      end
    end

    def on_message
      Proc.new do |on|
        on.message do |channel, message|
          puts "#{channel}: #{unpack(message)}"
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

    def unpack(message)
      MessagePack.unpack(message)
    end

    def shutdown_gracefully
      Signal.trap "SIGTERM", shutdown
      Signal.trap "SIGINT", shutdown
      Signal.trap "SIGQUIT", shutdown
    end

    def shutdown
      Proc.new do
        Redis.current.disconnect
        puts "\n#{self.class} shutting down..."
        exit 0
      end
    end
  end
end
