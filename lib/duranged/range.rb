module Duranged
  class Range < Duration
    class << self
      def load(json)
        hash = JSON.load(json)
        new(hash['start_at'].to_datetime, hash['end_at'].to_datetime)
      end
    end

    # Range.new(Time.now, 1.hour)
    # Range.new(Time.now, 1.hour.from_now)
    # Range.new(Time.now, (Time.now + 1.hour))
    # Range.new(1.hour)                         # start_at defaults to now
    # Range.new(1.hour.from_now)                # start_at defaults to now
    # Range.new(Time.now + 1.hour)              # start_at defaults to now
    def initialize(*args)
      if args.length == 2
        start_at, end_at_or_duration = *args
      elsif args.length == 1
        start_at = DateTime.now
        end_at_or_duration = args.first
      else
        raise ArgumentError, "wrong number of arguments (#{args.length} for 1..2)"
      end

      @start_at = start_at.to_datetime
      if end_at_or_duration.is_a?(Integer) || end_at_or_duration.is_a?(ActiveSupport::Duration)
        super(end_at_or_duration.to_i)
        @end_at = (@start_at + duration.seconds).to_datetime
      elsif end_at_or_duration.is_a?(Hash) || end_at_or_duration.is_a?(String)
        super(end_at_or_duration)
        @end_at = (@start_at + duration.seconds).to_datetime
      else
        @end_at = end_at_or_duration.to_datetime
        super(@end_at.to_i - @start_at.to_i)
      end
    end

    def start_at(format=nil)
      format.nil? ? @start_at : @start_at.strftime(format)
    end
    alias_method :start_date, :start_at
    alias_method :start_time, :start_at

    def end_at(format=nil)
      format.nil? ? @end_at : @end_at.strftime(format)
    end
    alias_method :end_date, :end_at
    alias_method :end_time, :end_at

    def to_duration
      Duration.new(duration)
    end

    def as_json(options=nil)
      { start_at: start_at.as_json,
        end_at: end_at.as_json }.merge(super)
    end
    alias_method :to_h, :as_json

    def to_s(format='%l:%M%P')
      if same_day?
        "#{start_at(format)} to #{end_at(format)}"
      else
        "#{start_at(format)} (#{super()})"
      end
    end

    def call
      to_s
    end

    protected

    def same_day?
      days? == 0 && start_at('%j') == end_at('%j')
    end
  end
end
