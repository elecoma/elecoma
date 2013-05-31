# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Style do
  fixtures :styles, :style_categories,:product_styles,:products, :retailers
  before(:each) do
    @style = styles(:can_incriment)
  end
  describe "validateチェック" do
    it "データがただしい" do
      @style.should be_valid
    end
    it "規格名" do
      #必須チェック
      @style.name = nil
      @style.should_not be_valid
      #重複チェック
      @style.name = styles(:can_not_incriment).name
      @style.should_not be_valid
    end
    it "retailer_idのチェック" do 
      max_retailer = Retailer.find(:last).id + 100
      @style.retailer_id = max_retailer
      @style.should_not be_valid
      @style.retailer_id = Retailer::DEFAULT_ID
      @style.should be_valid
    end
  end
  describe "その他" do
    it "商品を持っているか判断" do
      #商品を持っていない
      style = Style.new(:name => "テストです")
      style.save!
      style.style_categories.build
      3.times do |i|
        style.style_categories[i] = StyleCategory.new(:name =>"てすと")
      end
      style.has_product?.should be_false
      #商品を持っている
      @style.has_product?.should be_true
    end
  end  

  describe "select_options" do
    it "retailer_id = 1のケース" do
      array = Style.select_options
      array.size.should >= 300
    end

    it "retailer_id = 2のケース" do
      array = Style.select_options(nil, 2)
      array.size.should <= 300
    end
  end
end
