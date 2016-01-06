RSpec.shared_examples "a hash method" do |method|
  it 'returns a hash of the days, hours, minutes and seconds' do
    expect(subject.send(method)).to eq({years: 0, months: 0, weeks: 0, days_after_weeks: 1, days: 1, hours: 0, minutes: 2, seconds: 2})
  end
end

RSpec.shared_examples "a format conversion" do |period, formatter|
  context "using the #{period} formatter %#{formatter}" do
    it 'returns the formatted string' do
      expect(subject.strfdur("%#{formatter}")).to eq subject.send(:zero_pad, subject.send(period)) % subject.send(period)
    end
    
    context 'with a padding modifier' do
      it 'uses the provided padding' do
        expect(subject.strfdur("%5#{formatter}")).to eq subject.send(:zero_pad, subject.send(period), 5) % subject.send(period)
      end

      context 'with a padding negator' do
        it 'strips all padding' do
          expect(subject.strfdur("%-5#{formatter}")).to eq (subject.send(:zero_pad, subject.send(period), 5) % subject.send(period)).to_i.to_s.lstrip
        end
      end
    end

    context 'with a padding negator' do
      it 'strips all padding' do
        expect(subject.strfdur("%-#{formatter}")).to eq (subject.send(:zero_pad, subject.send(period)) % subject.send(period)).to_i.to_s.lstrip
      end
    end

    context 'when using the space padding flag' do
      it 'returns the formatted string' do
        expect(subject.strfdur("%_#{formatter}")).to eq subject.send(:space_pad, subject.send(period)) % subject.send(period)
      end

      context 'with a padding modifier' do
        it 'uses the provided padding' do
          expect(subject.strfdur("%_5#{formatter}")).to eq subject.send(:space_pad, subject.send(period), 5) % subject.send(period)
        end
      end
    end
  end
end

RSpec.shared_examples "a complex format string" do |duration, formatter, string|
  context "using complex formatter '#{formatter}'" do
    subject { Duranged::Duration.new(duration) }

    it "returns '#{string}'" do
      expect(subject.strfdur(formatter)).to eq string
    end
  end
end

RSpec.shared_examples "the base class" do |klass|
  subject { klass.new(86522.seconds) }

  describe 'dump' do
    it 'dumps the value as an integer' do
      expect(klass.dump(subject)).to eq subject.to_json
    end
  end

  describe 'load' do
    it 'creates a new value from the integer' do
      expect(klass.load(subject.to_json)).to be_an_instance_of klass
      expect(klass.load(subject.to_json).to_json).to eq subject.to_json
    end
  end

  describe '#initialize' do
    context 'when passed an integer' do
      it 'sets the value to the integer value' do
        expect(subject.value).to eq 86522
      end
    end

    context 'when passed a hash' do
      subject { klass.new({days: 1, hours: 0, minutes: 2, seconds: 2}) }

      it 'parses the hash keys into time values and sums them' do
        expect(subject.value).to eq 86522
      end
    end

    context 'when passed a parseable string' do
      subject { klass.new("1 day, 2 minutes, 2 seconds") }

      it 'parses the hash keys into time values and sums them' do
        expect(subject.value).to eq 86522
      end
    end
  end

  describe '#days?' do
    it 'returns the total number of days' do
      expect(subject.days).to eq 1
    end
  end

  describe '#hours?' do
    it 'returns the remainder of hours' do
      expect(subject.hours).to eq 0
    end
  end

  describe '#minutes?' do
    it 'returns the remainder of minutes' do
      expect(subject.minutes).to eq 2
    end
  end

  describe '#seconds?' do
    it 'returns the remainder of seconds' do
      expect(subject.seconds).to eq 2
    end
  end

  describe '#+' do
    context 'when passed an integer' do
      it 'returns an instance of the same class' do
        expect(subject + 20).to be_an_instance_of subject.class
      end

      it 'adds the integer to the value' do
        expect((subject + 20).value).to eq (subject.value + 20)
      end
    end

    context 'when passed a duration' do
      it 'returns an instance of the same class' do
        expect(subject + Duranged::Duration.new(20)).to be_an_instance_of subject.class
      end

      it 'adds the duration to the value' do
        expect((subject + Duranged::Duration.new(20)).value).to eq (subject.value + 20)
      end
    end

    context 'when passed an interval' do
      it 'returns an instance of the same class' do
        expect(subject + Duranged::Interval.new(20)).to be_an_instance_of subject.class
      end

      it 'adds the interval to the value' do
        expect((subject + Duranged::Interval.new(20)).value).to eq (subject.value + 20)
      end
    end
  end

  describe '#-' do
    context 'when passed an integer' do
      it 'returns an instance of the same class' do
        expect(subject - 20).to be_an_instance_of subject.class
      end

      it 'adds the integer to the value' do
        expect((subject - 20).value).to eq (subject.value - 20)
      end
    end

    context 'when passed a duration' do
      it 'returns an instance of the same class' do
        expect(subject - Duranged::Duration.new(20)).to be_an_instance_of subject.class
      end

      it 'adds the duration to the value' do
        expect((subject - Duranged::Duration.new(20)).value).to eq (subject.value - 20)
      end
    end

    context 'when passed an interval' do
      it 'returns an instance of the same class' do
        expect(subject - Duranged::Interval.new(20)).to be_an_instance_of subject.class
      end

      it 'adds the interval to the value' do
        expect((subject - Duranged::Interval.new(20)).value).to eq (subject.value - 20)
      end
    end
  end

  describe '#round_to!' do
    context 'when passed minutes' do
      it 'calls #round_to_minutes!' do
        expect(subject).to receive(:round_to_minutes!)
        subject.round_to! :minutes
      end
    end

    context 'when passed hours' do
      it 'calls #round_to_hours!' do
        expect(subject).to receive(:round_to_hours!)
        subject.round_to! :hours
      end
    end

    context 'when not passed a period' do
      it 'calls #round_to_minutes!' do
        expect(subject).to receive(:round_to_minutes!)
        subject.round_to!
      end
    end
  end

  describe '#round_to_minutes!' do
    it 'returns self' do
      expect(subject.round_to_minutes!).to eq subject
    end

    context 'when seconds is >= 30' do
      subject { klass.new(3630.seconds) }

      it 'rounds up to the next minute' do
        expect(subject.round_to_minutes!.value).to eq 3660
      end
    end

    context 'when seconds is < 30' do
      subject { klass.new(3620.seconds) }

      it 'rounds down to the minute' do
        expect(subject.round_to_minutes!.value).to eq 3600
      end
    end
  end

  describe '#round_to_hours!' do
    it 'returns self' do
      expect(subject.round_to_hours!).to eq subject
    end

    context 'when minutes is >= 30' do
      subject { klass.new(90.minutes) }

      it 'rounds up to the next hour' do
        expect(subject.round_to_hours!.value).to eq 2.hours
      end
    end

    context 'when minutes is < 30' do
      subject { klass.new(80.minutes) }

      it 'rounds down to the hour' do
        expect(subject.round_to_hours!.value).to eq 1.hour
      end
    end
  end

  describe '#as_json' do
    it 'returns the value integer' do
      expect(subject.as_json).to eq subject.value
    end
  end

  describe '#to_h' do
    it_behaves_like "a hash method", :to_h
  end

  describe '#to_s' do
    context 'when no format is specified' do
      it 'returns a string using the default format' do
        expect(subject.to_s).to eq '1 day, 2 minutes, 2 seconds'
      end
    end
  end

  describe '#strfdur' do
    context 'when no format is provided' do
      it 'raises an ArgumentError' do
        expect { subject.strfdur }.to raise_error(ArgumentError)
      end
    end

    context 'when a format is specified' do
      it_behaves_like "a format conversion", :seconds, 's'
      it_behaves_like "a format conversion", :minutes, 'm'
      it_behaves_like "a format conversion", :hours, 'h'
      it_behaves_like "a format conversion", :days, 'd'
      it_behaves_like "a format conversion", :days_after_weeks, 'D'
      it_behaves_like "a format conversion", :weeks, 'w'
      it_behaves_like "a format conversion", :months, 'M'
      it_behaves_like "a format conversion", :years, 'y'


      it_behaves_like "a complex format string", (3.days + 1.hour + 5.minutes + 30.seconds), '%d:%h:%m:%s', '03:01:05:30'
      it_behaves_like "a complex format string", (5.hours + 5.minutes), '%_h hours and %m minutes', ' 5 hours and 05 minutes'
      it_behaves_like "a complex format string", (3.days + 1.hour + 5.minutes + 30.seconds), '%-d days, %-h hour, %-m minutes, %-s seconds', '3 days, 1 hour, 5 minutes, 30 seconds'
    end
  end
end
