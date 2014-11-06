# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductOrderUnit do
  fixtures :product_order_units, :products ,:product_styles ,:carts ,:product_sets
  before(:each) do
    @pou_mono = product_order_units(:valid_product)
    @pou_set = product_order_units(:valid_product_set)
    @pou_new = ProductOrderUnit.new
    @product_style = product_styles(:valid_product)
  end

  describe "validateチェック" do
    it "データが正しい" do
      @pou_mono.should be_valid
      @pou_set.should be_valid
    end

    it "値段がないと失敗する" do
      @pou_mono.sell_price = nil
      @pou_mono.should_not be_valid
    end

    it "セットであればset_idが必須" do
      @pou_new.set_flag = true
      @pou_new.product_set_id = nil
      @pou_new.product_style_id = 14
      @pou_new.should_not be_valid
    end

    it "セットでなければstyle_idが必須" do
      @pou_new.set_flag = false
      @pou_new.product_set_id = 1
      @pou_new.product_style_id = nil
      @pou_new.should_not be_valid
    end
  end

  describe "機能を果たすかチェック" do
    it "OrderUnitからProductを参照できる" do
      @product_mono = @pou_mono.ps.product
      @product_mono.should == products(:valid_product)

      @product_set = @pou_set.ps.product
      @product_set.should == products(:valid_set_product)      
    end

    it "受注により在庫数が変わる" do
      @pou_mono.product_style_id = @product_style.id

      #在庫数1000、販売可能数100
      #購入後、在庫数と販売可能数とも引く
      cnt_before = @pou_mono.product_style.actual_count
      orderable_cnt_before = @pou_mono.product_style.orderable_count
      @pou_mono.order(2)
      @pou_mono.product_style.actual_count.should == cnt_before - 2
      @pou_mono.product_style.orderable_count.should == orderable_cnt_before - 2

      #在庫数0
      @pou_mono.product_style.actual_count = 0
      @pou_mono.product_style.orderable_count = 0
      #例外が発生する箇所を、lambdaでくくる必要がある
      lambda{
        @pou_mono.order(1)
      }.should raise_error(RuntimeError,"在庫不足です。")
    end

    it "受注により在庫数が変わる；セット商品" do
      @pou_mono.product_style_id = @product_style.id

      #在庫数1000、販売可能数100
      #購入後、在庫数と販売可能数とも引く
      @ps1 = product_styles(:can_incriment)
      @ps2 = product_styles(:valid_product)
      @pou_set.product_set.product_style_ids = "#{@ps1.id},#{@ps2.id}"
      @pou_set.product_set.ps_counts = "1,1"
      
      cnt_before1 = @ps1.actual_count
      cnt_before2 = @ps2.actual_count
      orderable_cnt_before1 = @ps1.orderable_count
      orderable_cnt_before2 = @ps2.orderable_count

      @pou_set.order(2)
      @ps1 = ProductStyle.find_by_id(@ps1.id)
      @ps2 = ProductStyle.find_by_id(@ps2.id)
      @ps1.actual_count.should == cnt_before1 - 2
      @ps2.actual_count.should == cnt_before2 - 2
      @ps1.orderable_count.should == orderable_cnt_before1 - 2
      @ps2.orderable_count.should == orderable_cnt_before2 - 2

      #在庫数0
      @ps1.actual_count = 0
      @ps1.orderable_count = 0
      @ps1.save!
      #例外が発生する箇所を、lambdaでくくる必要がある
      lambda{
        @pou_set.order(1)
      }.should raise_error(RuntimeError,"在庫不足です。")
    end

    it "販売可能なら数量を返す" do
      @carts = [carts(:cart_by_have_cart_user_one),carts(:cart_by_have_cart_user_two)] 

      #購入可能である(正常)
      @pou_mono.available?(@carts,3).should == 3
      @pou_set.available?(@carts,3).should == 3

      #購入することが出来ない
      @pou_mono.product_style.actual_count = 0
      @pou_mono.product_style.orderable_count = 0
      @pou_mono.available?(@carts,10).should_not == 10 
      @pou_set.available?(@carts,100).should_not == 100
    end
  end

end
