require 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'shared/base_examples.rb')

RSpec.describe Duranged::Duration do
  it_behaves_like "the base class", Duranged::Duration

  describe '#duration' do
    subject { Duranged::Duration.new(30.seconds) }

    it 'returns the duration value' do
      expect(subject.duration).to eq(subject.value)
    end
  end
end
