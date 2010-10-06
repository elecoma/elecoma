# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Payment do
  fixtures :payments
  
  before(:each) do
    @payment = payments :cash
  end
  
  describe "validateチェック" do
    it "データが正しい" do
      @payment.should be_valid
    end
    
    it "支払方法 名" do
      #必須チェック
      @payment.name  = ""
      @payment.should_not be_valid
      @payment.name  = "x"
      @payment.should be_valid
    end
    
    it "手数料 " do
      #必須チェック
      @payment.fee  = ""
      @payment.should_not be_valid
      #0円以上
      @payment.fee  = 0
      @payment.should be_valid
      @payment.fee  = -1
      @payment.should_not be_valid
      
    end
        
    it "利用条件 0円以上" do
      @payment.upper_limit  = -1
      @payment.should_not be_valid
      @payment.upper_limit  = 0
      @payment.should be_valid
      @payment.lower_limit  = -1
      @payment.should_not be_valid
      @payment.lower_limit  = 0
      @payment.should be_valid
    end
    
    it "利用条件 大小比較" do
      @payment.lower_limit  = 2
      @payment.upper_limit  = 1
      @payment.should_not be_valid
      
      @payment.lower_limit  = 1
      @payment.upper_limit  = 2
      @payment.should be_valid
      
      @payment.lower_limit  = 1
      @payment.upper_limit  = 1
      @payment.should be_valid
      
      @payment.lower_limit  = nil
      @payment.upper_limit  = 2
      @payment.should be_valid
      
      @payment.lower_limit  = 1
      @payment.upper_limit  = nil
      @payment.should be_valid
      
      @payment.lower_limit  = nil
      @payment.upper_limit  = nil
      @payment.should be_valid
    end
    
    it "金額 99999999以下" do
      @payment.fee  = 100000000
      @payment.should_not be_valid
      @payment.fee  = 99999999
      @payment.should be_valid
      @payment.upper_limit  = 100000000
      @payment.should_not be_valid
      @payment.upper_limit  = 99999999
      @payment.should be_valid
      @payment.lower_limit  = 100000000
      @payment.should_not be_valid
      @payment.lower_limit  = 99999999
      @payment.should be_valid
    end
    
  end
  
  describe "その他" do
    it "金額に合う支払い方法の一覧を出力" do
      Payment.find_for_price(1000).should == [payments(:cash),payments(:food)]
      Payment.find_for_price(1000000).should == [payments(:cash),payments(:food),payments(:from1million)]
      Payment.find_for_price(1).should == [payments(:cash),payments(:food),payments(:to1)]
      Payment.find_for_price(40000).should == [payments(:cash),payments(:food),payments(:from_million)]
    end
  end
end
