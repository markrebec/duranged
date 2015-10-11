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

      @interval = Interval.new(interval) if interval
      @duration = Duration.new(duration) if duration
      if range_start.present?
        if range_end_or_duration.nil?
          range_end_or_duration = range_start.to_datetime
          range_end_or_duration = range_end_or_duration + (@interval.value * (occurrences - 1)).seconds if @interval
          range_end_or_duration = range_end_or_duration + (@duration.value * occurrences).seconds if @duration
        end
        @range = Range.new(range_start, range_end_or_duration)
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

      if duration.present? && duration > 0
        str << "for"
        str << duration.to_s
      end

      if interval.present? && interval > 0
        str << "every"
        str << interval.to_s
      end

      if range.present?
        if range.same_day?
          str << range.strfrange("on :start_at(#{Duranged.configuration.formats.date}) between :start_at(#{Duranged.configuration.formats.time}) and :end_at(#{Duranged.configuration.formats.time})")
        else
          str << range.strfrange("between :start_at(#{Duranged.configuration.formats.date} #{Duranged.configuration.formats.time}) and :end_at(#{Duranged.configuration.formats.date} #{Duranged.configuration.formats.time})")
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
          matched = send(matches[1])
          value = matched.nil? ? '' : matched.strfdur(matches[3])
          str.gsub!(matches[0], value)
        end
      end

      str
    end
  end
end
