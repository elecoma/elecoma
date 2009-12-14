require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryTime do
  fixtures :delivery_times
  
  before(:each) do
    @delivery_time = delivery_times :morning
  end
  
  describe "validateチェック" do
    it "データがただしい" do
      @delivery_time.should be_valid
    end
    it "配送時間 必須ではない" do
      @delivery_time.name  = nil
      @delivery_time.should be_valid
      @delivery_time.name  = "x"
      @delivery_time.should be_valid
    end
  end
  
end
