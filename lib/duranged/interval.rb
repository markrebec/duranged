module Duranged
  class Interval < Base
    alias_attribute :interval, :value
    alias_method :interval_string, :to_s
  end
end
