# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Retailer do
  
  describe "validateチェック" do
    before do
      @retailer = Retailer.new
    end
    it "初期状態" do
      @retailer.should_not be_valid
    end
    it "販売元名称を追加" do
      @retailer.name = "販売元テスト"
      @retailer.should be_valid
    end
    it "販売元名称(カナ)はカタカナのみ受け付ける" do
      @retailer.name = "販売元テスト"
      @retailer.name_kana = "ハンバイモトテスト"
      @retailer.should be_valid
      @retailer.name_kana = "ハンバイモトテスト漢字入り"
      @retailer.should_not be_valid
    end
  end
end
