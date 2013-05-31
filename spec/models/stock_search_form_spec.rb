# -*- coding: utf-8 -*-
require 'spec_helper'

describe StockSearchForm do
  before(:each) do
    @search_form = StockSearchForm.new
  end
  describe "validateチェック" do
    it "データがただしい" do
      @search_form.should be_valid
    end
    it "商品ID" do
      #数字
      @search_form.product_id = 123456
      @search_form.should be_valid
      @search_form.product_id = "abc"
      @search_form.should_not be_valid
    end
    it "商品コード" do
      #英数字
      @search_form.code = "abc"
      @search_form.should be_valid
      @search_form.code = "あああ"
      @search_form.should_not be_valid
    end
    it "型番" do
      #英数字
      @search_form.manufacturer = "abc"
      @search_form.should be_valid
      @search_form.manufacturer = "123$%&"
      @search_form.should_not be_valid
    end
  end
end
