module Duranged
  class Base
    include Comparable
    include Periods

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
      str = strfparts(str)

      # %y %M %w %d %m %s
      str = strfformatters(str)

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

    def strfparts(str)
      PARTS.each do |part|
        while matches = str.match(/:(#{part})(\((.+)\))?/i) do
          if matches[3]
            str = strfpart(str, part)
          else
            # if no nested format was passed, replace with a singular
            # or plural part name as appropriate
            value = send(part) == 1 ? matches[1].to_s.singularize : matches[1].to_s

            str.gsub!(matches[0], value)
          end
        end
      end

      str
    end

    def strfpart(str, part)
      matched = parse_match(str)
      value = send(part) > 0 ? strfdur(matched.dup) : ''

      str.gsub!(":#{part}(#{matched})", value)
    end

    def strfformatters(str)
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

    def pad_value(value, pad=2, with=:zero)
      send("#{with}_pad".to_sym, value, pad)
    end

    def zero_pad(value, pad=2)
      "%0#{pad}d" % value
    end

    def space_pad(value, pad=2)
      "%#{pad}d" % value
    end

    def parse_match(match_str)
      match_substr = ''
      depth = 0
      match_str.chars.to_a.each do |char|
        depth += 1 if char == '('
        depth -= 1 if char == ')'
        break if depth == -1
        match_substr += char
      end
      match_substr
    end
  end
end
