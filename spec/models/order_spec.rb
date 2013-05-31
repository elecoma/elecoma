# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Order do
  fixtures :customers, :orders, :order_deliveries, :order_details
  before(:each) do
    #会員
    @order = orders(:customer_buy_two)
    #非会員
    @order2 = orders(:not_customer_buy_two_with_option_deliv)
  end

  describe "validateチェック" do
    it "データが正しい" do
      @order.should be_valid
      @order2.should be_valid
    end
  end

  describe "テーブル関連" do
    it "顧客" do
      #会員
      @order.customer.should_not be_nil
      @order.customer.should == customers(:valid_customer)
      #非会員
      @order2.customer.should be_nil
    end
  
    it "複数の発送情報 (order_delivery) を持つ" do
      @order.should have_at_least(1).order_delivery
      @order2.should have_at_least(1).order_delivery
    end
  end

  describe "金額計算" do
      before(:each) do
        @deliveries = order_deliveries(:customer_buy_two)
      end

    it "小計" do
      #fixturesのデータ      
      @order.subtotal.should == @deliveries.subtotal
      #データ再設定してテスト
      sum = 0
      @order.order_deliveries.each_with_index do |od,i|
        @order.order_deliveries[i].subtotal = 1000 + i * 100
        sum += @order.order_deliveries[i].subtotal
      end
      @order.subtotal.should == sum
    end
  
    it "購入金額合計" do
      #fixturesのデータ 
      @order.total.should == @deliveries.total
      #データ再設定してテスト
      sum = 0
      @order.order_deliveries.each_with_index do |od,i|
        @order.order_deliveries[i].total = 1000 + i * 100
        sum += @order.order_deliveries[i].total
      end
      @order.total.should == sum
    end
  
    it "支払い合計" do
      #fixturesのデータ 
      @order.payment_total.should == @deliveries.payment_total
      #データ再設定してテスト
      sum = 0
      @order.order_deliveries.each_with_index do |od,i|
        @order.order_deliveries[i].payment_total = 1000 + i * 100
        sum += @order.order_deliveries[i].payment_total
      end
      @order.payment_total.should == sum
    end
  
    it "受注金額" do
      #fixturesのデータ 
      @order.proceeds.should == @deliveries.proceeds
      #データ再設定してテスト
      sum = 0
      @order.order_deliveries.each_with_index do |od,i|
        @order.order_deliveries[i].total = 1000
        @order.order_deliveries[i].charge = 10
        sum += @order.order_deliveries[i].proceeds
      end
      @order.proceeds.should == sum
    end
  
    it 'find_sum' do
      expected = order_deliveries(:customer_buy_two)
      actual = Order.find_sum('orders.id = '+@order.id.to_s)
      actual.subtotal.should == expected.subtotal
      actual.total.should == expected.total
      actual.payment_total.should == expected.payment_total
      actual.charge.should == expected.charge
      actual.deliv_fee.should == expected.deliv_fee
      actual.discount.should == expected.discount
    end
  end

  describe "受注コード" do
    it "作成時に受注コードを採番する" do
      order = Order.new(@order.attributes)
      order.code = nil
      order.save
      order.code.should_not be_nil
      #受注コード=システム時間（分まで）＋レコードIDの下４桁
      order.code.should == order.created_at.strftime("%Y%m%d%H%M") + ("%04d" % order.id).slice(-4..-1)
    end
  
    it "更新時には受注コードはそのまま" do
      code = '1234567890'
      @order.code = code
      @order.save
      @order.code.should == code
    end    
  end
end
