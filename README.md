# Duranged

A set of classes to facilitate working with and formatting durations, intervals, time ranges and occurrences.

```ruby
Duranged::duration(300)               # 5 minute duration
Duranged::interval(1.hour)            # 1 hour interval
Duranged::range(Time.now, 30.minutes) # between now -> 30 minutes from now
Duranged::occurrence(1, 2.days)       # once every 2 days
```

## Durations / Intervals

A `Duranged::Duration` or `Duranged::Interval` represents a chunk of time. Their behavior is identical, and the names are mostly just aliases for different contexts and uses. The only difference is that durations respond to `Duranged::Duration#duration` while intervals respond to `Duranged::Interval#interval`, but both are just aliases for `#value`. Most of the examples below will use a duration.

Durations and intervals can be initialized with an integer, an `ActiveSupport::Duration` (i.e. `3.minutes`), a hash or a string (via the [chronic_duration](https://github.com/hpoydar/chronic_duration) gem).

```ruby
duration = Duranged::Duration.new(300)
#=> #<Duranged::Duration:0x007feb020f80f8 @value=300>

duration = Duranged::Duration.new(20.minutes)
#=> #<Duranged::Duration:0x007feb038534f0 @value=1200>

duration = Duranged::Duration.new({minutes: 5, seconds: 30})
#=> #<Duranged::Duration:0x007feb03838d08 @value=330>

duration = Duranged::Duration.new("1 day, 2 hours and 30 minutes")
#=> #<Duranged::Duration:0x007feb023a2650 @value=95400>
```

You can use the `#to_s` method for default string formatting, provided by `chronic_duration`.

```ruby
duration = Duranged::Duration.new(1.day + 12.minutes + 2.hours + 60.minutes)
duration.to_s
#=> "1 day, 3 hours, 12 minutes"
```

Or the `#strfdur` method for custom formatting, similiar to `Time#strftime`.

```ruby
duration = Duranged::Duration.new(1.day + 12.minutes + 2.hours + 32.seconds)
#=> #<Duranged::Duration:0x007faf693ab1d0 @value=94352> 

# standard, zero-padded formatters
duration.strfdur('%d:%h:%m:%s')
#=> "01:02:12:32" 

# prefix with _ flag for space padding
duration.strfdur('%_d:%_h:%_m:%_s')
#=> " 1: 2:12:32" 

# pass a modifier to control the amount of padding
duration.strfdur('%5d:%_5h:%m:%s')
#=> "00001:    2:12:32" 

# negate padding with a - flag
duration.strfdur('%-d day, %h hours, %m minutes and %s seconds')
#=> "1 day, 02 hours, 12 minutes and 32 seconds" 
```

The `#strfdur` method also accepts some custom formatters.

```ruby
duration = Duranged::Duration.new(12.hours + 30.minutes)
#=> #<Duranged::Duration:0x007faf692d38c0 @value=45000>

# use :days() to only show the formatted string when the value is > 0
duration.strfdur(':days(%d days, )%h hours and %m:seconds(:%s) minutes')
#=> "12 hours and 30 minutes" 

# versus without the custom formatter
duration.strfdur('%d days, %h hours and %m:%s minutes')
#=> "00 days, 12 hours and 30:00 minutes" 
```

If you pass a custom formatter **without** a nested format argument, it will return the singular or plural part name.

```ruby
duration = Duranged::Duration.new(2.days + 1.hours + 30.minutes)
#=> #<Duranged::Duration:0x007faf6921b388 @value=178200>

# :hours will be replaced with singular 'hour'
duration.strfdur(':days(%-d :days, )%-h :hours and %m :minutes')
#=> "2 days, 1 hour and 30 minutes" 

# your case will be preserved
duration.strfdur(':days(%-d :Days, )%-h :HOURS and %m :MiNuTeS')
#=> "2 Days, 1 HOUR and 30 MiNuTeS"
```

**TODO** See the wiki for a full list of formatters.

## Ranges

A `Duranged::Range` represents a specific chunk of time between a start and end time. Ranges can be initialized with an optional start time (defaults to now) and an end time or duration.

```ruby
range = Duranged::Range.new(Time.now, 30.minutes)
#=> #<Duranged::Range:0x007faaaca86e80 @start_at=Sun, 11 Oct 2015 12:27:31 -0700, @value=1800, @end_at=Sun, 11 Oct 2015 12:57:31 -0700>

range = Duranged::Range.new(Time.now, Time.now.end_of_day)
#=> #<Duranged::Range:0x007faaadb5baf8 @start_at=Sun, 11 Oct 2015 12:28:13 -0700, @value=41506, @end_at=Sun, 11 Oct 2015 23:59:59 -0700>

range = Duranged::Range.new(Time.now.end_of_day)
#=> #<Duranged::Range:0x007faaadb3b910 @start_at=Sun, 11 Oct 2015 12:28:44 -0700, @value=41475, @end_at=Sun, 11 Oct 2015 23:59:59 -0700>

range = Duranged::Range.new(3.hours)
#=> #<Duranged::Range:0x007faaadb29fa8 @start_at=Sun, 11 Oct 2015 12:29:26 -0700, @value=10800, @end_at=Sun, 11 Oct 2015 15:29:26 -0700>
```

You can get string representations of ranges.

```ruby

# if the range falls within the same day
range = Duranged::Range.new(Time.now, 2.hours)
#=> #<Duranged::Range:0x007faaadb112f0 @start_at=Sun, 11 Oct 2015 12:31:02 -0700, @value=7200, @end_at=Sun, 11 Oct 2015 14:31:02 -0700>
range.to_s
#=> "Oct. 11 2015 12:31pm to 2:31pm"

# if the rang spans more than one day
range = Duranged::Range.new(Time.now, Date.tomorrow.end_of_day)
#=> #<Duranged::Range:0x007faaadaea150 @start_at=Sun, 11 Oct 2015 12:32:27 -0700, @value=127652, @end_at=Mon, 12 Oct 2015 23:59:59 -0700>
range.to_s
#=> "Oct. 11 2015 12:32pm (1 day, 11 hours, 27 minutes, 32 seconds)"
```

And formatted strings with custom formatters.

```ruby
range = Duranged::Range.new(Time.now, Date.tomorrow.end_of_day)
#=> #<Duranged::Range:0x007faaadac3f50 @start_at=Sun, 11 Oct 2015 12:34:49 -0700, @value=127510, @end_at=Mon, 12 Oct 2015 23:59:59 -0700>

# :start_at and :end_at accept standard strftime formatters, :duration accepts Duranged::Duration formatters
range.strfrange('from :start_at(%b. %-d %Y) :start_at(%-l:%M%P) to :end_at(%b. %-d %Y %-l:%M%P) (:duration(%-d:%-h:%-m:%-s))')
#=> "from Oct. 11 2015 12:34pm to Oct. 12 2015 11:59pm (1:11:25:10)"
```

## Occurrences

A `Duration::Occurrence` represents an event that should happen **X times**, optionally for **Y duration**, every **Z interval**. For example "**work out** for **30 minutes** every **2 days**", or "water plants **once** every **2 days**".

**TODO** Document occurrences

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
