module Duranged
  class Base
    include Comparable
    attr_reader :value

    PARTS = [:years, :months, :weeks, :days_after_weeks, :days, :hours, :minutes, :seconds]
    FORMATTERS = { 's' => -> (pad,with) { pad_value seconds, pad, with },
                   'm' => -> (pad,with) { pad_value minutes, pad, with },
                   'h' => -> (pad,with) { pad_value hours, pad, with },
                   'd' => -> (pad,with) { pad_value days, pad, with },
                   'D' => -> (pad,with) { pad_value days_after_weeks, pad, with },
                   'w' => -> (pad,with) { pad_value weeks, pad, with },
                   'M' => -> (pad,with) { pad_value months, pad, with },
                   'y' => -> (pad,with) { pad_value years, pad, with } }

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

    def years
      (value.to_f / 60 / 60 / 24 / 365.25).to_i
    end

    def months
      (seconds_after_years / 60 / 60 / 24 / 30).floor
    end

    def weeks
      ((seconds_after_months / 60 / 60 / 24).floor / 7).floor
    end

    def days_after_weeks
      (seconds_after_weeks / 60 / 60 / 24).floor
    end

    def days_after_months
      (seconds_after_months / 60 / 60 / 24).floor
    end

    def days
      # TODO make this a configuration option with the ability to default to :days_after_weeks
      days_after_months
    end

    def hours
      (seconds_after_days / 60 / 60).floor
    end

    def minutes
      (seconds_after_hours / 60).floor
    end

    def seconds
      seconds_after_minutes.floor
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
      Hash[PARTS.map do |part|
        [part, send(part)]
      end]
    end

    def to_s
      ChronicDuration.output(value, format: :long, joiner: ', ').to_s
    end

    def strfdur(format)
      str = format.to_s

      # :years(%Y years, ):months(%N months, )%D :days
      PARTS.each do |part|
        while matches = str.match(/:(#{part})(\((.+)\))?/i) do
          if matches[3]
            # only replaces if the value is > 0, otherwise blank
            matched = ''
            depth = 0
            matches[3].chars.to_a.each do |char|
              depth += 1 if char == '('
              depth -= 1 if char == ')'
              break if depth == -1
              matched += char
            end
            value = send(part) > 0 ? strfdur(matched.dup) : ''
            str.gsub!(":#{part}(#{matched})", value)
          else
            # if no nested format was passed, replace with a singular
            # or plural part name as appropriate
            value = send(part) == 1 ? matches[1].to_s.singularize : matches[1].to_s
            str.gsub!(matches[0], value)
          end
        end
      end

      FORMATTERS.each do |conversion, block|
        while matches = str.match(/%([-_])?([0-9]+)?(#{conversion})/) do
          pad_with = matches[1] == '_' ? :space : :zero
          value = instance_exec(matches[2] || 2, pad_with, &block)
          value = value.to_i.to_s.lstrip if matches[1] == '-'

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

    def pad_value(value, pad=2, with=:zero)
      send("#{with}_pad".to_sym, value, pad)
    end

    def zero_pad(value, pad=2)
      "%0#{pad}d" % value
    end

    def space_pad(value, pad=2)
      "%#{pad}d" % value
    end

    def seconds_after_years
      value - years.years
    end

    def seconds_after_months
      seconds_after_years - months.months
    end

    def seconds_after_weeks
      seconds_after_months - weeks.weeks
    end

    def seconds_after_days
      seconds_after_months - days.days
    end

    def seconds_after_hours
      seconds_after_days - hours.hours
    end

    def seconds_after_minutes
      seconds_after_hours - minutes.minutes
    end
  end
end
