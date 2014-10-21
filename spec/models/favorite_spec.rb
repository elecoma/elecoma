# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Favorite do
  fixtures :favorites

  before(:each) do
    @exists_favorite = favorites(:exists_favorite)
    @favorite = Favorite.new
  end

  describe "validateチェック" do

    it "正しい値が入っていればデータが作成できる" do
      @favorite.customer_id = 1
      @favorite.product_order_unit_id = 3
      @favorite.save.should be_true
    end

    it "customer_idが無いと失敗" do
      @favorite.product_order_unit_id = 1
      @favorite.save.should be_false
    end

    it "product_order_unit_idが無いと失敗" do
      @favorite.customer_id = 1
      @favorite.save.should be_false
    end

    it "customer_idに数字以外が入っていると失敗" do
      @favorite.customer_id = 'test'
      @favorite.save.should be_false
    end

    it "product_order_unit_idに数字以外が入っていると失敗" do
      @favorite.product_order_unit_id = 'test'
      @favorite.save.should be_false
    end

    it "同じ商品を登録できない" do
      @favorite.customer_id = 1
      @favorite.product_order_unit_id = @exists_favorite.product_order_unit_id
      @favorite.save.should be_false
    end
  end
end
