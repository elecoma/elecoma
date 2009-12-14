require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductAccessLog do
  before(:each) do
    @product_access_log = ProductAccessLog.new
  end

  it "should be valid" do
    @product_access_log.should be_valid
  end
end
