require 'spec_helper'

RSpec.describe Duranged do
  describe 'duration' do
    it 'returns a Duranged::Duration' do
      expect(subject.duration(300.seconds)).to be_an_instance_of(Duranged::Duration)
    end
  end

  describe 'range' do
    it 'returns a Duranged::Range' do
      expect(subject.range(Time.now, (Time.now + 300.seconds))).to be_an_instance_of(Duranged::Range)
    end
  end
end
