require_relative '../check'

require 'hashr'
require 'redis/set'

module Check
  class Metric < Hashr
    DEFAULTS = {
      lower: 1,
      upper: 10,
      positives: 2,
      over_seconds: 60,
      suspend_after: 1,
      suspend_for: 1800
    }
    define(DEFAULTS)

    # In this example, we are overwriting the defaults so that all new
    # configs will consider 5 positives over a period of 60 seconds to
    # be a match.  The metric check will be suspended for 1h after 3
    # positive matches.
    #
    #   Check::Metric.defaults = {
    #     lower: 10,
    #     upper: 100,
    #     positives: 5,
    #     over_seconds: 60,
    #     suspend_after: 3,
    #     suspend_for: 3600
    #   }
    #
    def self.defaults=(params)
      define(params)
    end

    def self.delete_all(name)
      Redis.current.del(name)
    end

    def set
      return @set if @set

      @set = ::Redis::Set.new(self[:name], marshal: true) if valid_name?
    end

    def similar
      set.members.map do |member|
        Metric.new(member)
      end
    end

    def save
      set.add(self.to_hash) if valid?
    end

    def delete
      set.delete(self.to_hash)
    end

    def valid_name?
      !!self[:name]
    end

    def valid?
      valid_name?
    end

    def persisted?
      set.member?(self.to_hash)
    end
  end
end
