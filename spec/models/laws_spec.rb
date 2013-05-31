# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Law do
  fixtures :laws
  before(:each) do
    @laws = laws(:shoutorihiki)
    @text_field_maxlength = 200
    @text_field_overlength = @text_field_maxlength + 1
  end
  describe "validateチェック" do
    
    it "データがただしい" do
      @laws.should be_valid
    end
    
    it "販売業者" do
      #必須チェック
      @laws.company  = ""
      @laws.should_not be_valid
      #文字数（50以下）
      @laws.company = 'x' * 50
      @laws.should be_valid
      @laws.company = 'x' * 51
      @laws.should_not be_valid
    end
    
    it "運営責任者 " do
      #必須チェック
      @laws.manager  = ""
      @laws.should_not be_valid
      #文字数（50以下）
      @laws.manager = 'x' * 50
      @laws.should be_valid
      @laws.manager = 'x' * 51
      @laws.should_not be_valid
    end
    
    it "郵便番号前半" do
      #必須チェック
      @laws.zipcode01 = ""
      @laws.should_not be_valid
      #数字のみ
      @laws.zipcode01 = 'abc'
      @laws.should_not be_valid
      #3桁のみ
      @laws.zipcode01 = '1234'
      @laws.should_not be_valid
      @laws.zipcode01 = '12'
      @laws.should_not be_valid
    end
    
    it "郵便番号後半" do
      #必須チェック
      @laws.zipcode02 = ""
      @laws.should_not be_valid
      #数字のみ
      @laws.zipcode02 = 'abcd'
      @laws.should_not be_valid
      #4桁のみ
      @laws.zipcode02 = '45678'
      @laws.should_not be_valid
      @laws.zipcode02 = '456'
      @laws.should_not be_valid
    end
    
    it "都道府県" do
      #必須チェック
      @laws.prefecture_id = ""
      @laws.should_not be_valid
      #範囲
      @laws.prefecture_id = 0
      @laws.should_not be_valid
       (1..47).each do |i|
        @laws.prefecture_id = i
        @laws.should be_valid
      end
      @laws.prefecture_id = 48
      @laws.should_not be_valid
    end
    
    it "市区町村名" do
      #必須チェック
      @laws.address_city = ""
      @laws.should_not be_valid
      #文字数（50以下）
      @laws.address_city = 'x' * 50
      @laws.should be_valid
      @laws.address_city = 'x' * 51
      @laws.should_not be_valid
    end
    
    it "番地・ビル名" do
      #必須チェック
      @laws.address_detail = ""
      @laws.should_not be_valid
      #文字数（50以下）
      @laws.address_detail = 'x' * 50
      @laws.should be_valid
      @laws.address_detail = 'x' * 51
      @laws.should_not be_valid
    end
    
    it "電話番号1" do
      #必須チェック
      @laws.tel01 = ""
      @laws.should_not be_valid
      #数字のみ
      @laws.tel01 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.tel01 = '1234567'
      @laws.should_not be_valid
    end
    
    it "電話番号2: 必須" do
      #必須チェック
      @laws.tel02 = ""
      @laws.should_not be_valid
      #数字のみ
      @laws.tel02 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.tel02 = '1234567'
      @laws.should_not be_valid
    end
    
    it "電話番号3: 必須" do
      #必須チェック
      @laws.tel03 = ""
      @laws.should_not be_valid
      #数字のみ
      @laws.tel03 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.tel03 = '1234567'
      @laws.should_not be_valid
    end
    
    it "FAX番号" do
      #任意
      @laws.fax01 = ""
      @laws.should be_valid
      #数字のみ
      @laws.fax01 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.fax01 = '1234567'
      @laws.should_not be_valid
    end
    
    it "FAX番号2" do
      #任意
      @laws.fax02 = ""
      @laws.should be_valid
      #数字のみ
      @laws.fax02 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.fax02 = '1234567'
      @laws.should_not be_valid
    end
    
    it "FAX番号3" do
      #任意
      @laws.fax03 = ""
      @laws.should be_valid
      #数字のみ
      @laws.fax03 = 'abcd'
      @laws.should_not be_valid
      #6桁以下
      @laws.fax03 = '1234567'
      @laws.should_not be_valid
    end
    
    it "メールアドレス" do
      #必須チェック
      @laws.email = ""
      @laws.should_not be_valid
      #フォーマット
      @laws.email = 'foo@.com'
      @laws.should_not be_valid
      @laws.email = 'foo'
      @laws.should_not be_valid
      @laws.email = '@example.com'
      @laws.should_not be_valid
    end
    
    it "URL" do
      #文字数（50以下）
      suffix = 'http://'
      name = 'x' * (50 - suffix.size)
      url= suffix +name
      url.size.should == 50
      @laws.url =url
      @laws.should be_valid
      @laws.url = url +"x"
      @laws.should_not be_valid
      #フォーマット
      @laws.url = 'http'
      @laws.should_not be_valid
    end
    
    it "商品代金以外の必要料金" do
      #必須チェック
      @laws.necessary_charge  = ""
      @laws.should_not be_valid
      @laws.necessary_charge  = "x"
      @laws.necessary_charge_mobile  = ""
      @laws.should_not be_valid
      @laws.necessary_charge_mobile = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.necessary_charge = 'x' * @text_field_maxlength
      @laws.necessary_charge_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.necessary_charge = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.necessary_charge = 'x' * @text_field_maxlength
      @laws.necessary_charge_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end
    
    it "注文方法" do
      #必須チェック
      @laws.order_method  = ""
      @laws.should_not be_valid
      @laws.order_method  = "x"
      @laws.order_method_mobile = ""
      @laws.should_not be_valid
      @laws.order_method_mobile = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.order_method = 'x' * @text_field_maxlength
      @laws.order_method_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.order_method = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.order_method = 'x' * @text_field_maxlength
      @laws.order_method_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end
    
    it "支払方法" do
      #必須チェック
      @laws.payment_method  = ""
      @laws.should_not be_valid
      @laws.payment_method  = "x"
      @laws.payment_method_mobile  = ""
      @laws.should_not be_valid
      @laws.payment_method_mobile  = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.payment_method = 'x' * @text_field_maxlength
      @laws.payment_method_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.payment_method = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.payment_method = 'x' * @text_field_maxlength
      @laws.payment_method_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end
    
    it "支払期限" do
      #必須チェック
      @laws.payment_time_limit  = ""
      @laws.should_not be_valid
      @laws.payment_time_limit  = "x"
      @laws.payment_time_limit_mobile  = ""
      @laws.should_not be_valid
      @laws.payment_time_limit_mobile  = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.payment_time_limit = 'x' * @text_field_maxlength
      @laws.payment_time_limit_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.payment_time_limit = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.payment_time_limit = 'x' * @text_field_maxlength
      @laws.payment_time_limit_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end
    
    it "引き渡し時期 " do
      #必須チェック
      @laws.delivery_time  = ""
      @laws.should_not be_valid
      @laws.delivery_time  = "x"
      @laws.delivery_time_mobile  = ""
      @laws.should_not be_valid
      @laws.delivery_time_mobile  = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.delivery_time = 'x' * @text_field_maxlength
      @laws.delivery_time_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.delivery_time = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.delivery_time = 'x' * @text_field_maxlength
      @laws.delivery_time_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end
    
    it "返品・交換について" do
      #必須チェック
      @laws.return_exchange  = ""
      @laws.should_not be_valid
      @laws.return_exchange  = "x"
      @laws.return_exchange_mobile  = ""
      @laws.should_not be_valid
      @laws.return_exchange_mobile  = "x"
      @laws.should be_valid
      #文字数（200以下）
      @laws.return_exchange = 'x' * @text_field_maxlength
      @laws.return_exchange_mobile = 'x' * @text_field_maxlength
      @laws.should be_valid
      @laws.return_exchange = 'x' * @text_field_overlength
      @laws.should_not be_valid
      @laws.return_exchange = 'x' * @text_field_maxlength
      @laws.return_exchange_mobile = 'x' * @text_field_overlength
      @laws.should_not be_valid
    end

    it "販売元ID" do
      @laws.retailer_id = nil
      @laws.should_not be_valid
      @laws.retailer_id = 1
      @laws.should be_valid
    end

    it "表示フラグ" do
      @laws.render_type = nil
      @laws.should_not be_valid
      @laws.render_type = 0
      @laws.should be_valid
      @laws.render_type = 2
      @laws.should_not be_valid
    end

    it "重複登録が可能" do
      laws = Law.new(@laws.attributes)
      laws.retailer_id = 3
      laws.should be_valid
    end
  end
  describe "表示系" do
    it "郵便番号" do
      laws = Law.new(:zipcode01=>"103",:zipcode02=>"0003")
      laws.zipcode.should == "103-0003"
    end
    it "電話番号" do
      laws = Law.new(:tel01=>"010",:tel02=>"1234",:tel03=>"5678")
      laws.tel.should == "010-1234-5678"
    end
    it "ファックス番号" do
      laws = Law.new(:fax01=>"010",:fax02=>"1234",:fax03=>"5678")
      laws.fax.should == "010-1234-5678"
    end
  end
  describe "表示メソッド" do
    it "HTML表示" do
      @laws.render_type = 0
      @laws.should_not be_html
      @laws.render_type = 1
      @laws.should be_html
    end
  end

end
