require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Function do
  before(:each) do
    @function = Function.new
  end

  it "should be valid" do
    @function.should be_valid
  end
end
