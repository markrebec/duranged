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
    it "returns a string matching 'OCCURRENCES every INTERVAL'" do
      expect(subject.to_s).to eq "#{subject.occurrences_string} every #{subject.interval.to_s}"
    end

    context 'when interval is 0' do
      subject { Duranged::Occurrence.new(3, 0) }

      it 'returns the occurrences string' do
        expect(subject.to_s).to eq subject.occurrences_string
      end
    end

    context 'when occurrences is 0' do
      subject { Duranged::Occurrence.new(0, 30.seconds) }

      it 'returns the occurrences_string' do
        expect(subject.to_s).to eq subject.occurrences_string
      end
    end
  end
end
