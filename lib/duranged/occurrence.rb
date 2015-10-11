module Duranged
  class Occurrence
    attr_reader :occurrences, :interval, :duration, :range

    class << self
      def dump(obj)
        return if obj.nil?
        obj.to_json
      end

      def load(json)
        hash = JSON.load(json)
        args = [hash['occurrences'], hash['interval'], hash['duration']]
        args.concat [hash['range']['start_at'].to_datetime, hash['range']['end_at'].to_datetime] if hash.key?('range')
        new(*args)
      end
    end

    def initialize(occurrences=1, interval=nil, duration=nil, range_start=nil, range_end_or_duration=nil)
      if occurrences.class <= Enumerable
        @occurrences = occurrences.count
      else
        @occurrences = occurrences.to_i
      end

      @interval = Interval.new(interval)
      @duration = Duration.new(duration)
      if range_start.present? || range_end_or_duration.present?
        @range = Range.new(*[range_start, range_end_or_duration].compact)
      end
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
      hash = { occurrences: occurrences }
      hash[:interval] = interval.as_json(options) if interval
      hash[:duration] = duration.as_json(options) if duration
      hash[:range] = range.as_json(options) if range
      hash
    end
    alias_method :to_h, :as_json

    def to_s
      return occurrences_string if occurrences == 0

      str = [occurrences_string]

      if duration > 0
        str << "for"
        str << duration.to_s
      end

      if interval > 0
        str << "every"
        str << interval.to_s
      end

      if range.present?
        if range.same_day?
          str << range.strfrange('on :start_at(%b. %-d %Y) between :start_at(%-l:%M%P) and :end_at(%-l:%M%P)')
        else
          str << range.strfrange('between :start_at(%b. %-d %Y %-l:%M%P) and :end_at(%b. %-d %Y %-l:%M%P)')
        end
      end

      str.join(' ')
    end

    def strfocc(format)
      str = format.to_s

      while matches = str.match(/:occurrence[s]?/) do
        str.gsub!(matches[0], occurrences.to_s)
      end
      
      if range
        while matches = str.match(/:range(\((.+)\))?/) do
          if matches[2]
            matched = ''
            depth = 0
            matches[2].chars.to_a.each do |char|
              depth += 1 if char == '('
              depth -= 1 if char == ')'
              break if depth == -1
              matched += char
            end
            value = range.strfrange(matched.dup)
            str.gsub!(":range(#{matched})", value)
          else
            value = range.to_s
            str.gsub!(matches[0], value)
          end
        end
      end

      if duration || interval
        while matches = str.match(/:(duration|interval)(\(([^\)]+)\))/) do
          str.gsub!(matches[0], send(matches[1]).strfdur(matches[3]))
        end
      end

      str
    end
  end
end
