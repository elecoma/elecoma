require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MobileCarrier do
  before(:each) do
    @mobile_carrier = MobileCarrier.new
  end

  it "should be valid" do
    @mobile_carrier.should be_valid
  end
end
