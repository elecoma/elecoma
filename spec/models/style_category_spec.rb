# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StyleCategory do
  fixtures :style_categories,:product_styles
  before(:each) do
    @style_category = style_categories(:can_incriment)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @style_category.should be_valid
    end
    it "規格分類名" do
      #必須チェック
      @style_category.name = nil
      @style_category.should_not be_valid
    end
    it "規格ID" do
      #必須チェック
      style_category = StyleCategory.new
      style_category.should_not be_valid
    end
  end
  describe "その他" do
    it '商品を持っているか判断１-あり' do
      @style_category.save!
      ProductStyle.new(:style_category1 => @style_category).save_without_validation!
      @style_category.has_product?.should be_true
    end
  
    it '商品を持っているか判断２-あり' do
      @style_category.save!
      ProductStyle.new(:style_category2 => @style_category).save_without_validation!
      @style_category.has_product?.should be_true
    end
  
    it '商品を持っているか判断３-なし' do
      @style_category = StyleCategory.new
      @style_category.has_product?.should be_false
    end
  end
end
