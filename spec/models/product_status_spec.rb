# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductStatus do
  before(:each) do
    @product_status = ProductStatus.new
  end
  describe "validateチェック" do
    it "データがただしい" do
      @product_status.should be_valid
    end
  end
end
