require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Privacy do
  before(:each) do
    @privacies = Privacy.new
  end

  it "should be valid" do
    @privacies.should be_valid
  end
end
