require 'spec_helper'

RSpec.describe Duranged::Occurrence do
  subject { Duranged::Occurrence.new(5, 36.hours) }

  describe '#initialize' do
    context 'with occurrences' do
      it 'sets occurrences' do
        expect(subject.occurrences).to eq 5
      end
    end

    context 'without occurrences' do
      subject { Duranged::Occurrence.new }

      it 'sets occurrences to 1' do
        expect(subject.occurrences).to eq 1
      end
    end

    context 'with interval' do
      it 'sets interval' do
        expect(subject.interval).to eq 36.hours
      end
    end

    context 'without interval' do
      subject { Duranged::Occurrence.new }

      it 'sets interval to 0' do
        expect(subject.interval).to eq 0
      end
    end
  end

  describe '#occurrences_string' do
    context 'with zero occurrences' do
      subject { Duranged::Occurrence.new(0, 1.minute) }

      it "returns 'never'" do
        expect(subject.occurrences_string).to eq 'never'
      end
    end

    context 'with a single occurrence' do
      subject { Duranged::Occurrence.new(1, 1.minute) }

      it "returns 'once'" do
        expect(subject.occurrences_string).to eq 'once'
      end
    end

    context 'with two occurrences' do
      subject { Duranged::Occurrence.new(2, 1.minute) }

      it "returns 'twice'" do
        expect(subject.occurrences_string).to eq 'twice'
      end
    end

    context 'with multiple occurrences' do
      subject { Duranged::Occurrence.new([3,4,5].sample, 1.minute) }

      it "returns 'X times'" do
        expect(subject.occurrences_string).to eq "#{subject.occurrences} times"
      end
    end
  end

  describe '#as_json' do
    it 'returns a interval hash merged with occurrences' do
      expect(subject.as_json).to eq({occurrences: subject.occurrences, duration: subject.duration.as_json, interval: subject.interval.as_json})
    end
  end

  describe '#to_s' do
    subject { Duranged::Occurrence.new(3, 1.day, 10.minutes) }

    it "returns a string matching 'OCCURRENCES for DURATION every INTERVAL'" do
      expect(subject.to_s).to eq "#{subject.occurrences_string} for #{subject.duration.to_s} every #{subject.interval.to_s}"
    end

    context 'when occurrences is 0' do
      subject { Duranged::Occurrence.new(0, 30.seconds) }

      it 'returns the occurrences_string' do
        expect(subject.to_s).to eq subject.occurrences_string
      end

      it "returns 'never'" do
        expect(subject.to_s).to eq 'never'
      end
    end

    context 'when interval is 0' do
      subject { Duranged::Occurrence.new(3, 0, 30.seconds) }

      it "returns a string matching 'OCCURRENCES for DURATION'" do
        expect(subject.to_s).to eq "#{subject.occurrences_string} for #{subject.duration.to_s}"
      end

      context 'when duration is 0' do
        subject { Duranged::Occurrence.new(3) }

        it 'returns the occurrences string' do
          expect(subject.to_s).to eq subject.occurrences_string
        end
      end
    end

    context 'when duration is 0' do
      subject { Duranged::Occurrence.new(3, 1.day) }

      it "returns a string matching 'OCCURRENCES every INTERVAL'" do
        expect(subject.to_s).to eq "#{subject.occurrences_string} every #{subject.interval.to_s}"
      end

      context 'when interval is 0' do
        subject { Duranged::Occurrence.new(3) }

        it 'returns the occurrences string' do
          expect(subject.to_s).to eq subject.occurrences_string
        end
      end
    end
  end

  describe '#strfocc' do
    context 'using the :occurence token' do
      it 'returns the formatted string' do
        expect(subject.strfocc(':occurrence')).to eq subject.occurrences.to_s
      end
    end

    context 'using the :occurences token' do
      it 'returns the formatted string' do
        expect(subject.strfocc(':occurrences')).to eq subject.occurrences.to_s
      end
    end

    context 'using the :duration token' do
      it 'requires nested formatters' do
        expect(subject.strfocc(':duration')).to eq ':duration'
      end

      it 'returns the formatted string' do
        expect(subject.strfocc(':duration(%D:%H:%M:%S)')).to eq subject.duration.strfdur('%D:%H:%M:%S')
      end
    end

    context 'using the :interval token' do
      it 'requires nested formatters' do
        expect(subject.strfocc(':interval')).to eq ':interval'
      end

      it 'returns the formatted string' do
        expect(subject.strfocc(':interval(%D:%H:%M:%S)')).to eq subject.interval.strfdur('%D:%H:%M:%S')
      end
    end

    context 'using the :range token' do
      subject { Duranged::Occurrence.new(5, 10.minutes, 30.seconds, Time.now, Time.now + 1.hour) }

      context 'without nested formatters' do
        it 'returns the default formatted range string' do
          expect(subject.strfocc(':range')).to eq subject.range.to_s
        end
      end

      context 'with nested formatters' do
        it 'returns the formatted string' do
          expect(subject.strfocc(':range(:start_at(%l:%M%P) :end_at(%l:%M%P) :duration(%D%H%M%S))')).to eq "#{subject.range.start_at('%l:%M%P')} #{subject.range.end_at('%l:%M%P')} #{subject.range.strfdur('%D%H%M%S')}"
        end
      end
    end

    context "using complex format string ':occurrences times for :duration(%-s) seconds every :interval(%-m) minutes between :range(:start_at(%l:%M%P) and :end_at(%l:%M%P) (:duration(%-m minutes)))'" do
      subject { Duranged::Occurrence.new(3, 5.minutes, 30.seconds, DateTime.parse('2015-01-01T06:00:00-07:00'), DateTime.parse('2015-01-01T06:20:00-07:00')) }

      it "returns '3 times for 30 seconds every 5 minutes between 6:00am and 6:20am'" do
        expect(subject.strfocc(':occurrences times for :duration(%-s) seconds every :interval(%-m) minutes between :range(:start_at(%l:%M%P) and :end_at(%l:%M%P) (:duration(%-m minutes)))')).to eq '3 times for 30 seconds every 5 minutes between 6:00am and 6:20am (20 minutes)'
      end
    end

    context "using complex format string 'between :range(:start_at(%l:%M%P) and :end_at(%l:%M%P) (:duration(%-m minutes))), do something :occurrences times for :duration(%-s) seconds every :interval(%-m) minutes'" do
      subject { Duranged::Occurrence.new(3, 5.minutes, 30.seconds, DateTime.parse('2015-01-01T06:00:00-07:00'), DateTime.parse('2015-01-01T06:20:00-07:00')) }

      it "returns 'between 6:00am and 6:20am (20 minutes), do something 3 times for 30 seconds every 5 minutes'" do
        expect(subject.strfocc('between :range(:start_at(%l:%M%P) and :end_at(%l:%M%P) (:duration(%-m minutes))), do something :occurrences times for :duration(%-s) seconds every :interval(%-m) minutes')).to eq 'between 6:00am and 6:20am (20 minutes), do something 3 times for 30 seconds every 5 minutes'
      end
    end
  end
end
