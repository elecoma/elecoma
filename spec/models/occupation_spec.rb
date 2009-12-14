require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Occupation do
  before(:each) do
    @occupation = Occupation.new
  end

  it "should be valid" do
    @occupation.should be_valid
  end
end
