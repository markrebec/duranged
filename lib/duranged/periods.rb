module Duranged
  module Periods
    def years
      (value.to_f / 60 / 60 / 24 / 365.25).to_i
    end

    def months
      (seconds_after_years / 60 / 60 / 24 / 30).floor
    end

    def weeks
      ((seconds_after_months / 60 / 60 / 24).floor / 7).floor
    end

    def days_after_weeks
      (seconds_after_weeks / 60 / 60 / 24).floor
    end

    def days_after_months
      (seconds_after_months / 60 / 60 / 24).floor
    end

    def days
      # TODO make this a configuration option with the ability to default to :days_after_weeks
      days_after_months
    end

    def hours
      (seconds_after_days / 60 / 60).floor
    end

    def minutes
      (seconds_after_hours / 60).floor
    end

    def seconds
      seconds_after_minutes.floor
    end

    protected

    def seconds_after_years
      value - years.years
    end

    def seconds_after_months
      seconds_after_years - months.months
    end

    def seconds_after_weeks
      seconds_after_months - weeks.weeks
    end

    def seconds_after_days
      seconds_after_months - days.days
    end

    def seconds_after_hours
      seconds_after_days - hours.hours
    end

    def seconds_after_minutes
      seconds_after_hours - minutes.minutes
    end
  end
end
