module Duranged
  class Base
    include Comparable
    attr_reader :value

    PARTS = [:years, :months, :weeks, :days, :hours, :minutes, :seconds]
    FORMATTERS = { 'S' => -> (pad) { zero_pad seconds?, pad },
                   's' => -> (pad) { space_pad seconds?, pad },
                   'M' => -> (pad) { zero_pad minutes?, pad },
                   'm' => -> (pad) { space_pad minutes?, pad },
                   'H' => -> (pad) { zero_pad hours?, pad },
                   'h' => -> (pad) { space_pad hours?, pad },
                   'D' => -> (pad) { zero_pad days?, pad },
                   'd' => -> (pad) { space_pad days?, pad },
                   'W' => -> (pad) { zero_pad weeks?, pad },
                   'w' => -> (pad) { space_pad weeks?, pad },
                   'N' => -> (pad) { zero_pad months?, pad },
                   'n' => -> (pad) { space_pad months?, pad },
                   'Y' => -> (pad) { zero_pad years?, pad },
                   'y' => -> (pad) { space_pad years?, pad } }

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

    def years?
      (value.to_f / 60 / 60 / 24 / 365.25).to_i
    end

    def months?
      ((value - years?.years) / 60 / 60 / 24 / 30).floor
    end

    def weeks?
      (((value - months?.months - years?.years) / 60 / 60 / 24).floor / 7).floor
    end

    def days_after_weeks?
      ((value - weeks?.weeks - months?.months - years?.years) / 60 / 60 / 24).floor
    end

    def days?
      ((value - months?.months - years?.years) / 60 / 60 / 24).floor
    end

    def hours?
      ((value - days?.days - months?.months - years?.years) / 60 / 60).floor
    end

    def minutes?
      ((value - hours?.hours - days?.days - months?.months - years?.years) / 60).floor
    end

    def seconds?
      (value - minutes?.minutes - hours?.hours - days?.days - months?.months - years?.years).floor
    end

    def +(other)
      if other.is_a?(Duration) || other.is_a?(Interval)
        Duranged.logger.warn "Warning: You are adding a #{other.class.name} to a #{self.class.name}, which will result in a #{self.class.name}. If you would like a #{other.class.name} object to be returned you must add your #{self.class.name} to your #{other.class.name} instead." if other.is_a?(Range)
        self.class.new(value + other.value)
      elsif other.is_a?(Integer)
        self.class.new(value + other)
      else
        raise ArgumentError, "value must be an Integer, Duranged::Duration or Duranged::Interval"
      end
    end

    def -(other)
      if other.is_a?(Duration) || other.is_a?(Interval)
        Duranged.logger.warn "Warning: You are subtracting a #{other.class.name} from a #{self.class.name}, which will result in a #{self.class.name}. If you would like a #{other.class.name} object to be returned you must subtract your #{self.class.name} from your #{other.class.name} instead." if other.is_a?(Range)
        self.class.new(value - other.value)
      elsif other.is_a?(Integer)
        self.class.new(value - other)
      else
        raise ArgumentError, "value must be an Integer, Duranged::Duration or Duranged::Interval"
      end
    end

    def as_json(options=nil)
      value
    end

    def to_h
      PARTS.map do |part|
        [part, send("#{part}?")]
      end.to_h
    end

    def to_s
      ChronicDuration.output(value, format: :long, joiner: ', ').to_s
    end

    def strfdur(format)
      str = format.to_s

      FORMATTERS.each do |conversion, block|
        while matches = str.match(/%(-)?([0-9]+)?(#{conversion})/) do
          value = instance_exec(matches[2] || 2, &block)
          value = value.to_i.to_s.lstrip unless matches[1].nil?

          str.gsub!(matches[0], value)
        end
      end

      str
    end

    def to_i
      value
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

    def call
      value
    end

    protected

    def parse_hash(hash)
      hash.sum { |k,v| v.to_i.send(k.to_sym) }
    end

    def zero_pad(value, pad=2)
      "%0#{pad}d" % value
    end

    def space_pad(value, pad=2)
      "%#{pad}d" % value
    end
  end
end
