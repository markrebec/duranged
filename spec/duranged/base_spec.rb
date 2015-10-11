require 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'shared/base_examples.rb')

RSpec.describe Duranged::Base do
  it_behaves_like "the base class", Duranged::Base
end
