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
      @favorite.product_style_id = 2
      @favorite.save be_true
    end

    it "customer_idが無いと失敗" do
      @favorite.product_style_id = 1
      @favorite.save.should be_false
    end

    it "product_style_idが無いと失敗" do
      @favorite.customer_id = 1
      @favorite.save.should be_false
    end

    it "product_style_idに数字以外が入っていると失敗" do
      @favorite.product_style_id = 'test'
      @favorite.save.should be_false
    end

    it "product_style_idに数字以外が入っていると失敗" do
      @favorite.customer_id = 'test'
      @favorite.save.should be_false
    end

    it "同じ商品を登録できない" do
      @favorite.customer_id = 1
      @favorite.product_style_id = @exists_favorite.product_style_id
      @favorite.save.should be_false
    end
  end
end
