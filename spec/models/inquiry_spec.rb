# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Inquiry do
  fixtures :inquiries
  before(:each) do
    @inquiry = inquiries(:inquiry_test_id_1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @inquiry.should be_valid
    end
    
    it "メールアドレス" do
      #必須チェック
      @inquiry.email = nil
      @inquiry.should_not be_valid
      @inquiry.email = "aa"
      @inquiry.should_not be_valid
      @inquiry.email = "a@.com"
      @inquiry.should_not be_valid
      @inquiry.email = "a@softbank.ne.jp.jp"
      @inquiry.should_not be_valid
    end
    it "問い合わせ内容" do
      #必須チェック
      @inquiry.body = nil
      @inquiry.should_not be_valid
    end
    it "問い合わせ種類" do      
      #必須チェック
      @inquiry.kind = nil
      @inquiry.should_not be_valid      
    end
    it "お問い合わせ送信者名" do
      #必須チェック
      @inquiry.name = nil
      @inquiry.should_not be_valid      
    end
    it "電話番号" do
      #非必須
      @inquiry.tel = nil
      @inquiry.should be_valid
      #フォーマット
      @inquiry.tel = "080-1111-2222"
      @inquiry.should be_valid
      @inquiry.tel = "08011112222"
      @inquiry.should be_valid
      @inquiry.tel = "0801111222a"
      @inquiry.should_not be_valid
    end
  end
  
  describe "表示系" do
    it "問い合わせ種類" do
      inquiry = Inquiry.new(:kind=>Inquiry::GOODS)
      inquiry.show_kind_name.should == Inquiry::KIND_NAMES[Inquiry::GOODS]
    end
    
    it "PC問い合わせ種類リスト" do
      list = [[Inquiry::KIND_NAMES[Inquiry::GOODS], Inquiry::GOODS],
      [Inquiry::KIND_NAMES[Inquiry::CLAIM], Inquiry::CLAIM],
      [Inquiry::KIND_NAMES[Inquiry::SEND], Inquiry::SEND],
      [Inquiry::KIND_NAMES[Inquiry::CAMPAIGN], Inquiry::CAMPAIGN],
      [Inquiry::KIND_NAMES[Inquiry::RISAGASU], Inquiry::RISAGASU],
      [Inquiry::KIND_NAMES[Inquiry::SITE], Inquiry::SITE],
      [Inquiry::KIND_NAMES[Inquiry::OTHER], Inquiry::OTHER]]
      
      Inquiry.pc_kind_list.should == list
    end
    
    it "MB問い合わせ種類リスト" do
      list = [[Inquiry::KIND_NAMES[Inquiry::GOODS], Inquiry::GOODS],
      [Inquiry::KIND_NAMES[Inquiry::ORDER], Inquiry::ORDER],
      [Inquiry::KIND_NAMES[Inquiry::CLAIM], Inquiry::CLAIM],
      [Inquiry::KIND_NAMES[Inquiry::SEND], Inquiry::SEND],
      [Inquiry::KIND_NAMES[Inquiry::CAMPAIGN], Inquiry::CAMPAIGN],
      [Inquiry::KIND_NAMES[Inquiry::OTHER], Inquiry::OTHER]]
      
      Inquiry.mobile_kind_list.should == list
    end
  end
end
