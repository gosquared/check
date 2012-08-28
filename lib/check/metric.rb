require_relative '../check'

require 'hashr'
require 'redis/set'
require 'redis/list'
require 'redis/value'
require 'msgpack'

module Check
  class Metric < Hashr
    # If you really want to overwrite the defaults completely, inherit this
    # class and re-define self.defaults.  Don't forget to invoke the define
    # method with the new defaults as this is Hashr's way of defining the hash
    # blueprint.
    #
    # It would be interesting to go further with positives and categorize them
    # as consistent (>50% matches are lower or higher) or fluctuating (50/50).
    #
    def self.defaults
      {
        lower: 1,
        upper: 10,
        matches_for_positive: 2,
        over_seconds: 60,
        suspend_after_positives: 1,
        keep_positives: 10,
        suspend_for_seconds: 1800
      }
    end
    define self.defaults

    # In this example, we are overwriting the defaults so that all new
    # configs will consider 5 matches over a period of 60 seconds to
    # be a positive.  The metric check will be suspended for 1h after 3
    # positives.  The lower and upper bounds are also adjusted.
    #
    #   Check::Metric.defaults = {
    #     lower: 10,
    #     upper: 100,
    #     matches_for_positive: 5,
    #     over_seconds: 60,
    #     suspend_after_positives: 3,
    #     suspend_for_seconds: 3600
    #   }
    #
    def self.defaults=(params={})
      define self.defaults.merge(params)
    end

    def self.delete_all(name)
      Redis.current.del(name)
    end

    def self.find(params={})
      Metric.new(params)
    end

    def set
      return @set if @set
      @set = Redis::Set.new(self.fetch(:name)) if valid_name?
    end

    def similar
      set.members.map do |member|
        Metric.new(unpack(member))
      end
    end

    def pack
      self.to_hash.to_msgpack
    end
    alias :packed :pack

    def unpack(value)
      MessagePack.unpack(value)
    end

    def save
      set.add(packed) if valid?
      self
    end

    def delete
      delete_associated
      set.delete(packed)
    end

    def id
      hash.abs
    end

    def namespace(string)
      "#{self.fetch(:name)}:#{string}:#{self.id}"
    end

    def matches_key
      namespace("matches")
    end

    def positives_key
      namespace("positives")
    end

    def disable_key
      namespace("disable")
    end

    def matches
      return @matches if @matches
      @matches = Redis::List.new(matches_key, maxlength: self.fetch(:matches_for_positive), marshal: true)
    end

    def delete_matches
      Redis.current.del(matches_key)
    end
    # removing all elements from a list is the same as deleting that list altogether
    alias :clear_matches :delete_matches

    def positives
      return @positives if @positives
      @positives = Redis::List.new(positives_key, maxlength: self.fetch(:keep_positives), marshal: true)
    end

    def delete_associated
      Redis.current.del([matches_key, positives_key, disable_key])
    end

    def suspended?(timestamp=Time.now.utc.to_i)
      last_positive = positives.last

      if last_positive
        timestamp - last_positive.fetch(:timestamp) <= self.fetch(:suspend_for_seconds)
      else
        false
      end
    end

    def disable
      return @disable if @disable
      @disable = Redis::Value.new(disable_key, marshal: true)
    end

    def disable!
      disable.value = true
    end

    def enable!
      disable.delete
    end
    alias :delete_disable :enable!

    def disabled?
      disable.exists?
    end

    def trigger_positive?
      first_match = matches.first
      last_match = matches.last

      if first_match and last_match
        matches.length == self.fetch(:matches_for_positive) and
        last_match.fetch(:timestamp) - first_match.fetch(:timestamp) <= self.fetch(:over_seconds)
      end
    end

    def check(params)
      timestamp = params.fetch(:timestamp) { Time.now.utc }.to_i
      value = params.fetch(:value)

      similar.each do |metric|
        next if metric.suspended?(timestamp) or metric.disabled?

        unless value.between?(metric.fetch(:lower), metric.fetch(:upper))
          metric.matches.push({
            value: value,
            timestamp: timestamp
          })
        end

        if metric.trigger_positive?
          metric.positives.push({
            timestamp: metric.matches.last.fetch(:timestamp),
            matches: metric.matches.values
          })
          metric.clear_matches
        end
      end
    end

    def valid_name?
      !!(self.fetch(:name) { "" }.strip != "")
    end

    def valid?
      valid_name?
    end

    def persisted?
      set.include?(packed)
    end
  end
end
