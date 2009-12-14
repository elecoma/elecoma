require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthoritiesFunction do
  before(:each) do
    @authoritiesFunction = AuthoritiesFunction.new
  end

  it "should be valid" do
    @authoritiesFunction.should be_valid
  end
  
end
