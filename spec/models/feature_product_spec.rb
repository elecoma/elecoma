# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeatureProduct do
  fixtures :feature_products
  before(:each) do
    @feature_product = FeatureProduct.new(:product_id=>18,:feature_id=>1)
  end
  describe "validateチェック" do
    it "データがただしい" do
      @feature_product.should be_valid
    end
    it "商品ID" do
      #必須チェック
      @feature_product.product_id = nil
      @feature_product.should_not be_valid
    end
    it "特集ID" do
      #必須チェック
      @feature_product.feature_id = nil
      @feature_product.should_not be_valid
    end
  end
  describe "その他" do
    it "positionが自動的に1をプラス" do
      max = FeatureProduct.maximum(:position)
      #positionが自動的に1をプラス
      @feature_product.save!
      @feature_product.position.should == (max += 1)
      feature_product = FeatureProduct.new(:product_id=>19,:feature_id=>2)
      feature_product.save!
      feature_product.position.should == (max += 1)
    end
  end  
end
