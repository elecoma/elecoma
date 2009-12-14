require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Prefecture do
  before(:each) do
    @prefecture = Prefecture.new
  end

  it "should be valid" do
    @prefecture.should be_valid
  end
end
