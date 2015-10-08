## Duranged

```ruby
Duranged::duration(300)               # 5 minute duration
Duranged::interval(1.hour)            # 1 hour interval
Duranged::range(Time.now, 30.minutes) # between now -> 30 minutes from now
Duranged::occurrence(1, 2.days)       # once every 2 days
```

### Durations / Intervals

A `Duranged::Duration` or `Duranged::Interval` represents a chunk of time. Their behavior is identical, and the names are mostly just aliases for different contexts and uses. The only difference is that durations respond to `Duranged::Duration#duration` while intervals respond to `Duranged::Interval#interval`, but both are just aliases for `#value`. Most of the examples below will use a duration.

```ruby
duration = Duranged::Duration.new(300)
#=> #<Duranged::Duration:0x007feb020f80f8 @value=300>

duration = Duranged::Duration.new(20.minutes)
#=> #<Duranged::Duration:0x007feb038534f0 @value=1200>

duration = Duranged::Duration.new({minutes: 5, seconds: 30})
#=> #<Duranged::Duration:0x007feb03838d08 @value=330>

duration = Duranged::Duration.new("1 day, 2 hours and 30 minutes")
#=> #<Duranged::Duration:0x007feb023a2650 @value=95400>

duration = Duranged::Duration.new(1.day + 12.minutes + 2.hours + 60.minutes)
duration.to_s
#=> "1 day, 3 hours, 12 minutes"
```

### Ranges

A `Duranged::Range` represents a specific chunk of time between a start and end time.

```ruby
```

### Occurrences

A `Duration::Occurrence` represents an event that should happen **X times**, optionally for **Y duration**, every **Z interval**. For example "**work out** for **30 minutes** every **2 days**", or "water plants **once** every **2 days**".
