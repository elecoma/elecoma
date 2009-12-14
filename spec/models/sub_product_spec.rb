require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubProduct do
  before(:each) do
    @sub_product = SubProduct.new
  end

  describe "validateチェック" do
    it "データがただしい" do
      @sub_product.should be_valid
    end
  
    it "名前は100文字まで" do
      @sub_product.name = "x" * 100
      @sub_product.should be_valid
      @sub_product.name = "x" * 101
      @sub_product.should_not be_valid
    end
  
    it "コメントは100文字まで" do
      @sub_product.description = "x" * 100
      @sub_product.should be_valid
      @sub_product.description = "x" * 101
      @sub_product.should_not be_valid
    end  
  end
end
