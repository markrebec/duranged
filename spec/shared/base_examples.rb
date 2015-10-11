RSpec.shared_examples "a hash method" do |method|
  it 'returns a hash of the days, hours, minutes and seconds' do
    expect(subject.send(method)).to eq({days: 1, hours: 0, minutes: 2, seconds: 2})
  end
end

RSpec.shared_examples "a format conversion" do |period, formatter, printf_str|
  context "using the #{period} formatter %#{formatter}" do
    it 'returns the formatted string' do
      expect(subject.strfdur("%#{formatter}")).to eq printf_str % subject.send("#{period}?".to_sym)
    end
    
    context 'with a padding modifier' do
      it 'uses the provided padding' do
        expect(subject.strfdur("%5#{formatter}")).to eq printf_str.gsub('2','5') % subject.send("#{period}?".to_sym)
      end

      context 'with a padding negator' do
        it 'strips all padding' do
          expect(subject.strfdur("%-5#{formatter}")).to eq (printf_str.gsub('2','5') % subject.send("#{period}?".to_sym)).to_i.to_s.lstrip
        end
      end
    end

    context 'with a padding negator' do
      it 'strips all padding' do
        expect(subject.strfdur("%-#{formatter}")).to eq (printf_str % subject.send("#{period}?".to_sym)).to_i.to_s.lstrip
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
      it_behaves_like "a format conversion", :seconds, 'S', '%02d'
      it_behaves_like "a format conversion", :seconds, 's', '%2d'
      it_behaves_like "a format conversion", :minutes, 'M', '%02d'
      it_behaves_like "a format conversion", :minutes, 'm', '%2d'
      it_behaves_like "a format conversion", :hours, 'H', '%02d'
      it_behaves_like "a format conversion", :hours, 'h', '%2d'
      it_behaves_like "a format conversion", :days, 'D', '%02d'
      it_behaves_like "a format conversion", :days, 'd', '%2d'

      it_behaves_like "a complex format string", (3.days + 1.hour + 5.minutes + 30.seconds), '%D:%H:%M:%S', '03:01:05:30'
      it_behaves_like "a complex format string", (5.hours + 5.minutes), '%h hours and %M minutes', ' 5 hours and 05 minutes'
      it_behaves_like "a complex format string", (3.days + 1.hour + 5.minutes + 30.seconds), '%-d days, %-h hour, %-m minutes, %-s seconds', '3 days, 1 hour, 5 minutes, 30 seconds'
    end
  end
end
