require 'spec_helper'

RSpec.describe Duranged::Range do
  now = Time.now
  subject { Duranged::Range.new(now, 60.minutes) }

  describe 'dump' do
    it 'dumps the time range as a JSON hash' do
      expect(Duranged::Range.dump(subject)).to eq subject.to_json
    end
  end

  describe 'load' do
    it 'creates a new time range from a JSON hash' do
      puts subject.to_json
      expect(Duranged::Range.load(subject.to_json)).to be_an_instance_of Duranged::Range
      expect(Duranged::Range.load(subject.to_json).as_json).to eq subject.as_json
    end
  end

  describe '#initialize' do
    context 'with a start_at and end_at' do
      subject { Duranged::Range.new(now, (now + 60.minutes)) }

      it 'sets start_at' do
        expect(subject.start_at).to eq now
      end

      it 'sets end_at' do
        expect(subject.end_at).to eq(now + 60.minutes)
      end
    end

    context 'with a start_at and duration' do
      subject { Duranged::Range.new(now, 60.minutes) }

      it 'sets start_at' do
        expect(subject.start_at).to eq now
      end

      context 'when the duration is an ActiveSupport::Duration' do
        subject { Duranged::Range.new(now, 60.minutes) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(now + 60.minutes)
        end
      end

      context 'when the duration is an integer' do
        subject { Duranged::Range.new(now, 3600) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(now + 60.minutes)
        end
      end

      context 'when the duration is a hash' do
        subject { Duranged::Range.new(now, {minutes: 60}) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(now + 60.minutes)
        end
      end

      context 'when the duration is a string' do
        subject { Duranged::Range.new(now, "1 day, 2 hours and 30 minutes") }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(now + (26.hours + 30.minutes))
        end
      end
    end

    context 'with just a duration' do
      subject { Duranged::Range.new(60.minutes) }

      it 'sets start_at to now' do
        expect(subject.start_at).to be_between((Time.now - 1.seconds), Time.now)
      end

      context 'when the duration is an ActiveSupport::Duration' do
        subject { Duranged::Range.new(60.minutes) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(subject.start_at + 60.minutes)
        end
      end

      context 'when the duration is an integer' do
        subject { Duranged::Range.new(3600) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(subject.start_at + 60.minutes)
        end
      end

      context 'when the duration is a hash' do
        subject { Duranged::Range.new({minutes: 60}) }

        it 'sets end_at to start_at + duration' do
          expect(subject.end_at).to eq(subject.start_at + 60.minutes)
        end
      end
    end

    context 'with just an end_at' do
      subject { Duranged::Range.new(now + 60.minutes) }

      it 'sets start_at to now' do
        expect(subject.start_at).to be_between((Time.now - 1.seconds), Time.now)
      end

      it 'sets end_at' do
        expect(subject.end_at).to eq(now + 60.minutes)
      end
    end
  end

  describe '#start_at' do
    subject { Duranged::Range.new(now, 60.minutes) }

    context 'without a format argument' do
      it 'returns the start_at DateTime object' do
        expect(subject.start_at).to eq now
        expect(subject.start_at).to be_an_instance_of DateTime
      end
    end

    context 'with a format argument' do
      it 'returns a formatted string' do
        expect(subject.start_at('%A, %b %e, %Y %l:%M%P')).to eq now.strftime('%A, %b %e, %Y %l:%M%P')
      end
    end
  end

  describe '#end_at' do
    subject { Duranged::Range.new(now, 60.minutes) }

    context 'without a format argument' do
      it 'returns the end_at DateTime object' do
        expect(subject.end_at).to eq(now + 60.minutes)
        expect(subject.end_at).to be_an_instance_of DateTime
      end
    end

    context 'with a format argument' do
      it 'returns a formatted string' do
        expect(subject.end_at('%A, %b %e, %Y %l:%M%P')).to eq((now + 60.minutes).strftime('%A, %b %e, %Y %l:%M%P'))
      end
    end
  end

  describe '#to_h' do
    it 'returns a duration hash merged with start_at and end_at' do
      expect(subject.to_h).to eq({days: 0, hours: 1, minutes: 0, seconds: 0, start_at: subject.start_at.as_json, end_at: subject.end_at.as_json})
    end
  end

  describe '#as_json' do
    it 'returns a duration hash merged with start_at and end_at' do
      expect(subject.as_json).to eq({days: 0, hours: 1, minutes: 0, seconds: 0, start_at: subject.start_at.as_json, end_at: subject.end_at.as_json})
    end
  end

  describe '#to_duration' do
    it 'returns a duration object' do
      expect(subject.to_duration).to be_an_instance_of Duranged::Duration
    end

    it 'returns a duration object that represents the duration value' do
      expect(subject.to_duration.duration).to eq subject.duration
    end
  end

  describe '#to_s' do
    subject { Duranged::Range.new((now.beginning_of_day), 60.minutes) }

    context 'without a format argument' do
      it 'uses the default format' do
        format = '%l:%M%P'
        expect(subject.to_s).to eq "#{subject.start_at(format)} to #{subject.end_at(format)}"
      end
    end

    context 'with a format argument' do
      it 'uses the provided format' do
        format = '%H:%M:%S%P'
        expect(subject.to_s(format)).to eq "#{subject.start_at(format)} to #{subject.end_at(format)}"
      end
    end

    context 'when start and end fall on the same day' do
      subject { Duranged::Range.new((now.beginning_of_day + 30.minutes), (now.beginning_of_day + 5.hours)) }

      it 'returns the start and end times' do
        format = '%l:%M%P'
        expect(subject.to_s).to eq "#{subject.start_at(format)} to #{subject.end_at(format)}"
      end
    end

    context 'when start and end fall on different days' do
      subject { Duranged::Range.new((now.utc.end_of_day - 20.minutes), 30.minutes) }

      it 'returns the start time and duration' do
        format = '%l:%M%P'
        expect(subject.to_s).to eq "#{subject.start_at(format)} (#{Duranged::Duration.new(subject.duration).to_s})"
      end
    end
  end
end
