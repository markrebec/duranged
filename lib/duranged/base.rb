module Duranged
  class Base
    include Comparable
    include Periods
    include Formatters

    attr_reader :value

    class << self
      def dump(obj)
        return if obj.nil?
        obj.to_json
      end

      def load(json)
        value = JSON.load(json)
        new(value)
      end
    end

    def initialize(value)
      if value.is_a?(Hash)
        @value = parse_hash(value)
      elsif value.is_a?(String) && value.to_i.to_s != value
        @value = ChronicDuration.parse(value, keep_zero: true).to_i
      else
        @value = value.to_i
      end
    end

    def <=>(other)
      if value < other.to_i
        -1
      elsif value > other.to_i
        1
      else
        0
      end
    end

    def +(other)
      Duranged.logger.warn "Warning: You are adding a #{other.class.name} to a #{self.class.name}, which will result in a #{self.class.name}. If you would like a #{other.class.name} object to be returned you must add your #{self.class.name} to your #{other.class.name} instead." if other.is_a?(Range)
      self.class.new(to_i + other.to_i)
    end

    def -(other)
      Duranged.logger.warn "Warning: You are subtracting a #{other.class.name} from a #{self.class.name}, which will result in a #{self.class.name}. If you would like a #{other.class.name} object to be returned you must subtract your #{self.class.name} from your #{other.class.name} instead." if other.is_a?(Range)
      self.class.new(to_i - other.to_i)
    end

    def round_to(period=:minutes)
      dup.round_to!(period)
    end

    def round_to!(period=:minutes)
      send("round_to_#{period}!")
    end

    def round_to_minutes
      dup.round_to_minutes!
    end

    def round_to_minutes!
      if seconds >= 30
        @value = value + (60 - seconds)
      else
        @value = value - seconds
      end
      self
    end

    def round_to_hours
      dup.round_to_hours!
    end

    def round_to_hours!
      round_to_minutes!
      if minutes >= 30
        @value = value + (60 - minutes).minutes
      else
        @value = value - minutes.minutes
      end
      self
    end

    protected

    def parse_hash(hash)
      hash.sum { |k,v| v.to_i.send(k.to_sym) }
    end
  end
end
