require 'spec_helper'

RSpec.describe Duranged::Interval do
  it_behaves_like "the base class", Duranged::Interval

  describe '#interval' do
    subject { Duranged::Interval.new(30.seconds) }

    it 'returns the interval value' do
      expect(subject.interval).to eq(subject.value)
    end
  end
end
