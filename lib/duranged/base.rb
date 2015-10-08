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
      return ChronicDuration.output(value, format: :long, joiner: ', ').to_s

      #parts = PARTS.map do |part|
      #  value = send("#{part}?")
      #  maybe_pluralize(value, part.to_s) if value > 0
      #end.compact

      #return '' if parts.empty?
      #return parts.first if parts.count == 1

      #last = parts.slice!(-1)
      #[parts.join(', '), last].join(' and ')
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

    def maybe_pluralize(cnt, str)
      "#{cnt} #{cnt == 1 ? str.singularize : str.pluralize}"
    end

    def parse_hash(hash)
      hash.sum { |k,v| v.to_i.send(k.to_sym) }
    end
  end
end
