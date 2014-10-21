# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cart do
  fixtures :customers, :products, :carts, :product_styles, :styles, :style_categories,:campaigns,:product_order_units

  before(:each) do
    @cart = carts(:valid_cart)
  end
  
  describe "validateチェック" do
    it "データが正しい場合" do
      @cart.should be_valid
    end
    #ログインしている顧客はブラックリスト対象である場合
    it "black顧客の場合" do
      @cart.customer_id = customers(:black_customer).id
      @cart.should_not be_valid
    end
    #数量が0
    it "数量が0の場合" do
      @cart.quantity = 0
      @cart.should_not be_valid
    end
    #product_styleが空
    it "注文単位が存在しない場合" do
      @cart.product_order_unit_id = nil
      @cart.should_not be_valid
    end
    #購入可能な数量を超過しています
    it "購入可能な数量を超過しています" do
      @cart.quantity = 1001
      @cart.should_not be_valid
    end
    #キャンペーン商品
    it "キャンペーン商品" do
      #キャンペーン期間以内
      @cart.product_order_unit = product_order_units(:campaign_product)
      @cart.should be_valid
      #キャンペーン期間以外
      campaign = @cart.ps.product.campaign
      campaign.opened_at = DateTime.new(2008, 1, 1)
      campaign.closed_at = DateTime.new(2008, 12, 1)
      @cart.should_not be_valid      
    end
    #未公開商品
    it "未公開商品" do
      @cart.product_order_unit = product_order_units(:not_permit_product)
      @cart.should_not be_valid
    end
    #販売期間外商品
    it "販売期間商品" do
      @cart.product_order_unit = product_order_units(:sell_stop_product)
      @cart.should_not be_valid
    end
  end
  describe "金額計算系" do
    it "小計" do
      @cart.subtotal.should == product_order_units(:valid_product).sell_price * 1
      cart = Cart.new(:product_order_unit_id => 20,:quantity =>2)
      cart.subtotal.should == product_order_units(:multi_styles_product_3).sell_price * 2
      cart = Cart.new
      cart.subtotal.should be_nil
    end
  end
  
end
