require 'active_support'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/time'
require 'canfig'
require 'chronic_duration'
require 'duranged/base'
require 'duranged/duration'
require 'duranged/interval'
require 'duranged/occurrence'
require 'duranged/range'

module Duranged
  PARTS = [:days, :hours, :minutes, :seconds]
  CONVERSIONS = { 'S' => -> (pad) { zero_pad seconds?, pad },
                  's' => -> (pad) { space_pad seconds?, pad },
                  'M' => -> (pad) { zero_pad minutes?, pad },
                  'm' => -> (pad) { space_pad minutes?, pad },
                  'H' => -> (pad) { zero_pad hours?, pad },
                  'h' => -> (pad) { space_pad hours?, pad },
                  'D' => -> (pad) { zero_pad days?, pad },
                  'd' => -> (pad) { space_pad days?, pad } }

  include Canfig::Module

  configure do |config|
    config.formats = Canfig.new(date: '%b. %-d %Y', time: '%-l:%M%P')
    config.logger = ActiveSupport::Logger.new(STDOUT)
  end

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
