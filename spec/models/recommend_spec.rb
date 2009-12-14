require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Recommend do
  before(:each) do
    @recommend = Recommend.new
  end

  it "should be valid" do
    @recommend.should be_valid
  end
end
