# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderDetail do
  fixtures :order_details, :styles, :product_styles,:products,:style_categories
  before(:each) do
    #会員
    @order_detail = order_details(:customer_buy_one)
    #非会員
    @order_detail2 = order_details(:not_customer_buy_one)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @order_detail.should be_valid
      @order_detail2.should be_valid
    end
    it "単価" do
      #必須
      @order_detail.price = nil
      @order_detail.should_not be_valid
    end
    it "数量" do
      #必須
      @order_detail.quantity = nil
      @order_detail.should_not be_valid
    end
  end
  
  describe "金額計算" do
    it "小計 (単価 + 税額) * 数" do
      #fixturesのデータ      
      @order_detail.subtotal.should == (@order_detail.price.to_i + @order_detail.tax_price.to_i)*@order_detail.quantity.to_i
      #データ再設定してテスト
      @order_detail.price = 1000
      @order_detail.tax_price = 50
      @order_detail.quantity = 2
      @order_detail.subtotal.should ==  2100
      
      @order_detail.tax_price = nil
      @order_detail.subtotal.should ==  2000
      
      
    end
    it "税込価格(商品1個あたり)" do
      #fixturesのデータ      
      @order_detail.price_with_tax.should == @order_detail.price.to_i + @order_detail.tax_price.to_i
      #データ再設定してテスト
      @order_detail.price = 1000
      @order_detail.tax_price = 50
      @order_detail.price_with_tax.should == 1050
      @order_detail.tax_price = nil
      @order_detail.price_with_tax.should == 1000
    end
  end
  
  describe "商品名[ 規格名1[ 規格名2]] 出力" do
    it "商品名表示" do
      product_name = products(:campaign_product).name
      product_style1 = style_categories(:have_classcateogry1).name
      product_style2 = style_categories(:can_incriment).name
      @order_detail.product_style_name.should == product_name + ' '+product_style1+' '+product_style2
    end
  end
end
