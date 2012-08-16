require_relative '../check'

require 'hashr'
require 'redis/set'

module Check
  class MissingNameError < StandardError; end

  class Metric < Hashr
    define({
      lower:                  0,
      upper:                  0,
      checks:                 1,
      over_seconds:           60,
      suspend_after_matches:  5,
      suspend_for:            600
    })

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

    class << self
      def delete_all(name)
        Redis.current.del(name)
      end
    end
  end
end
