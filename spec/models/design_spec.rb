require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Design do
  before(:each) do
    @design = Design.new
  end

  it "should be valid" do
    @design.should be_valid
  end
end
