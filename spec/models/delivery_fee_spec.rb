# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryFee do
  fixtures :delivery_fees,:prefectures
  
  before(:each) do
    @delivery_fee = delivery_fees :delivery_fee_1
  end
  
  describe "validateチェック" do
    it "データがただしい" do
      @delivery_fee.should be_valid
    end
    
    it "金額 必須" do
      @delivery_fee.price = ""
      @delivery_fee.should_not be_valid
    end
    
    it "金額  数字のみ" do
      @delivery_fee.price = '123'
      @delivery_fee.should be_valid
      @delivery_fee.price = 'abc'
      @delivery_fee.should_not be_valid
    end

    it "金額  マイナス不許可" do
      @delivery_fee.price = '-123'
      @delivery_fee.should_not be_valid
    end
  end
  
  describe "表示系" do
    it "県名" do
      @delivery_fee.prefecture_name.should == prefectures(:prefecture_00001).name
      delivery_fee = DeliveryFee.new(:prefecture_id =>48)
      delivery_fee.prefecture_name.should == "離島"
    end
  end
  
  describe "バリデーションメッセージ" do
    it '値段に数値以外' do
      @delivery_fee.price = '123abc'
      @delivery_fee.should_not be_valid
      @delivery_fee.errors.full_messages[0].should == '価格は数値で入力してください。'
    end
  end
end
