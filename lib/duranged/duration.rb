module Duranged
  class Duration < Base
    alias_attribute :duration, :value
    alias_method :duration_string, :to_s
  end
end
