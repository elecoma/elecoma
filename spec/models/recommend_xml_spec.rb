require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecommendXml do
  before(:each) do
    @recommend_xml = RecommendXml.new
  end

  it "should be valid" do
    @recommend_xml.should be_valid
  end
end
