require 'active_support'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/time'
require 'chronic_duration'
require 'duranged/base'
require 'duranged/duration'
require 'duranged/interval'
require 'duranged/occurrence'
require 'duranged/range'

module Duranged
  PARTS = [:days, :hours, :minutes, :seconds]

  def self.interval(interval)
    Interval.new(interval)
  end

  def self.duration(duration)
    Duration.new(duration)
  end

  def self.range(start_at, end_at_or_duration)
    Range.new(start_at, end_at_or_duration)
  end

  def self.occurrence(occurrences=1, interval=nil, duration=nil)
    Occurrence.new(occurrences, interval, duration)
  end
end
