RSpec.shared_examples "a hash method" do |method|
  it 'returns a hash of the days, hours, minutes and seconds' do
    expect(subject.send(method)).to eq({days: 1, hours: 0, minutes: 2, seconds: 2})
  end
end

RSpec.shared_examples "a string method" do |method|
  it 'returns a string representation of the value' do
    expect(subject.send(method)).to eq '1 day, 2 minutes, 2 seconds'
  end
end

RSpec.shared_examples "the base class" do |klass|
  subject { klass.new(86522.seconds) }

  describe 'dump' do
    it 'dumps the value as a JSON hash' do
      expect(klass.dump(subject)).to eq subject.to_json
    end
  end

  describe 'load' do
    it 'creates a new value from a JSON hash' do
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
      expect(subject.days?).to eq 1
    end
  end

  describe '#hours?' do
    it 'returns the remainder of hours' do
      expect(subject.hours?).to eq 0
    end
  end

  describe '#minutes?' do
    it 'returns the remainder of minutes' do
      expect(subject.minutes?).to eq 2
    end
  end

  describe '#seconds?' do
    it 'returns the remainder of seconds' do
      expect(subject.seconds?).to eq 2
    end
  end

  describe '#as_json' do
    it_behaves_like "a hash method", :as_json
  end

  describe '#to_h' do
    it_behaves_like "a hash method", :to_h
  end

  describe '#to_s' do
    it_behaves_like "a string method", :to_s
  end
end
