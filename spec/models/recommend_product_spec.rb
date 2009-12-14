require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecommendProduct do
  
  before(:each) do
    @recommend_product = RecommendProduct.new(:product_id=>18,:description=>"オススメ商品のテストコードです")
  end
  describe "validateチェック" do
    it "データが正しい" do
      @recommend_product.should be_valid
    end    
    it "商品ID" do
      #必須チェック
      recommend_product = RecommendProduct.new(:description=>"オススメ商品のテストコードです")
      recommend_product.should_not be_valid
    end
    it "オススメコメント" do
      #必須チェック
      recommend_product = RecommendProduct.new(:product_id=>18)
      recommend_product.should_not be_valid
      
      #文字数チェック(300文字以下)
      recommend_product.description = "あ" * 300
      recommend_product.should be_valid
      recommend_product.description = "a" * 301
      recommend_product.should_not be_valid
    end  
  end
  describe "その他" do
    it "positionが自動的に1プラス" do
      RecommendProduct.delete_all
      RecommendProduct.count.should == 0
      @recommend_product.position.should be_nil
      @recommend_product.position_up
      @recommend_product.save!
      @recommend_product.position.should == 1
      recommend_product = RecommendProduct.new(:product_id=>16,:description=>"オススメ商品のテストコードです")
      recommend_product.position_up
      recommend_product.save!
      recommend_product.position.should == 2
    end
  end  
end
