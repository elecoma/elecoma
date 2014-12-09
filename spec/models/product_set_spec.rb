# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ProductSet do
fixtures :product_set_styles, :product_sets, :product_styles
  describe "validateチェック" do
    before do
      @product_set = ProductSet.new(
         :product_id => 1
      )
    end

    it "正しい値が入っていればデータが作成できる" do
      @product_set.product_style_ids = '1,4'
      @product_set.ps_counts = '2,2'
      @product_set.save.should be_true
    end

    it "produc_style_idsが存在しないと失敗" do
      @product_set.product_style_ids = ''
      @product_set.ps_counts = '2,3'
      @product_set.save.should be_false
    end

    it "product_style_idsが正規表現に合っていないと失敗" do
      @product_set.product_style_ids = 'a,h,10s'
      @product_set.ps_counts = '1,1,1'
      @product_set.save.should be_false     
    end

    it "product_style_idsが20個までなら作成できる" do
      @product_set.product_style_ids = '1'
      @product_set.ps_counts = '1'
      2.upto(20) do |num|
        @product_set.product_style_ids << ",#{num}"
        @product_set.ps_counts << ',1'
      end
      @product_set.save.should be_true
    end

    it "product_style_idsが20個を超えると失敗" do
      @product_set.product_style_ids = '1'
      @product_set.ps_counts = '1'
      2.upto(30) do |num|
        @product_set.product_style_ids << ",#{num}"
        @product_set.ps_counts << ',1'
      end
      @product_set.save.should be_false
    end

    it "style_idsとps_countsの要素サイズが等しくないと失敗" do
      @product_set.product_style_ids = '1,2,3,4,5'
      @product_set.ps_counts = '1,2'
      @product_set.save.should be_false
    end    
    it "受注により在庫数が変わる" do
      @product_style = product_styles(:valid_product)
      @valid_set = product_sets(:valid_set)
      #在庫数1000、販売可能数100
      #購入後、在庫数と販売可能数とも引く
      cnt_b = @product_style.actual_count
      orderable_cnt_b = @product_style.orderable_count
      @valid_set.order(2)
      @product_style = ProductStyle.find_by_id(@product_style.id)
      @product_style.actual_count.should == cnt_b-2
      @product_style.orderable_count.should == orderable_cnt_b - 2
    end  
  end
end
