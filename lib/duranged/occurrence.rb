module Duranged
  class Occurrence
    attr_reader :occurrences, :duration, :interval

    def initialize(occurrences=1, interval=nil, duration=nil)
      if occurrences.class <= Enumerable
        @occurrences = occurrences.count
      else
        @occurrences = occurrences.to_i
      end

      @interval = Interval.new(interval)
      @duration = Duration.new(duration)
    end

    def occurrences_string
      case occurrences
      when 0
        "never"
      when 1
        "once"
      when 2
        "twice"
      else
        "#{occurrences} times"
      end
    end

    def as_json(options=nil)
      { occurrences: occurrences,
        duration: duration.as_json(options),
        interval: interval.as_json(options) }
    end
    alias_method :to_h, :as_json

    def to_s
      return occurrences_string if occurrences == 0

      str = []
      if occurrences > 0
        str << occurrences_string

        if duration > 0
          str << "for"
        end
      end
      str << duration.to_s if duration > 0

        if interval > 0
          str << "every"
          str << interval.to_s
        end

      str.join(' ')
    end
  end
end
