module Duranged
  class Base
    include Comparable
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

    def days?
      value / 60 / 60 / 24
    end

    def hours?
      value / 60 / 60 % 24
    end

    def minutes?
      value / 60 % 60
    end

    def seconds?
      value % 60
    end

    def as_json(options=nil)
      PARTS.map do |part|
        [part, send("#{part}?")]
      end.to_h
    end
    alias_method :to_h, :as_json

    def to_s
      ChronicDuration.output(value, format: :long, joiner: ', ').to_s
    end

    def strfdur(format)
      str = format.to_s

      Duranged::CONVERSIONS.each do |conversion, block|
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
