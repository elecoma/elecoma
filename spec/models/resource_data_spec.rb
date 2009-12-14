require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceData do
  before(:each) do
    @resouce_data = ResourceData.new
  end

  it "should be valid" do
    @resouce_data.should be_valid
  end
end
