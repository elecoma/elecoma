require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Seo do
  
  before(:each) do
    @seo = Seo.new
  end
  describe "validateチェック" do
    it "データが正しい" do
      @seo.should be_valid
    end
    it "author" do
      #文字数（50以下）
      @seo.author = 'x' * 50
      @seo.should be_valid
      @seo.author = 'x' * 51
      @seo.should_not be_valid
    end
    it "description" do
      #文字数（50以下）
      @seo.description = 'x' * 50
      @seo.should be_valid
      @seo.description = 'x' * 51
      @seo.should_not be_valid
    end
    it "keywords" do
      #文字数（50以下）
      @seo.keywords = 'x' * 50
      @seo.should be_valid
      @seo.keywords = 'x' * 51
      @seo.should_not be_valid
    end  
  end
  describe "その他" do
    it "ページ名自動保存" do
      #ページ名nilの場合
      @seo.name.should be_nil
      @seo.save
      @seo.name.should be_nil
      #ページ名がnilではない場合
      seo = Seo.new(:page_type=>Seo::PRODUCTS_LIST)
      seo.save
      seo.name.should == Seo::TYPE_NAMES[Seo::PRODUCTS_LIST]
    end
  end
end
