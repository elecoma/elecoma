# -*- coding: utf-8 -*-
require 'spec_helper'

describe Supplier do
  fixtures :suppliers, :retailers
  before(:each) do
    @supplier = suppliers(:one)
  end

  describe "validateチェック" do
    it "データが正しい" do
      @supplier.should be_valid
    end
    it "仕入先名" do
      #必須
      @supplier.name = ""
      @supplier.should_not be_valid
      #文字数
      @supplier.name = "あ" * 50
      @supplier.should be_valid
      @supplier.name = "あ" * 51
      @supplier.should_not be_valid
    end
    it "担当者名" do
      #必須
      @supplier.contact_name = ""
      @supplier.should_not be_valid
      #文字数
      @supplier.contact_name = "あ" * 50
      @supplier.should be_valid
      @supplier.contact_name = "あ" * 51
      @supplier.should_not be_valid
    end
    it "住所" do
      @supplier.address_city = ""
      @supplier.should_not be_valid
      
      @supplier.address_city = "あ" * 101
      @supplier.should_not be_valid
      
      @supplier.address_city = "あ" * 100
      @supplier.should be_valid
      
      @supplier.address_detail = ""
      @supplier.should_not be_valid
      
      @supplier.address_detail = "a" * 101
      @supplier.should_not be_valid
      
      @supplier.address_detail = "a" * 100
      @supplier.should be_valid
    end
    it "電話番号1" do
      #必須
      @supplier.tel01 = nil
      @supplier.should_not be_valid
      #数字
      @supplier.tel01 = "aaa"
      @supplier.should_not be_valid
      #桁数
      @supplier.tel01 = "1" * 7
      @supplier.should_not be_valid
      @supplier.tel01 = "1" * 6
      @supplier.should be_valid      
    end
    it "電話番号2" do
      #必須
      @supplier.tel02 = nil
      @supplier.should_not be_valid
      #数字
      @supplier.tel02 = "aaa"
      @supplier.should_not be_valid
      #桁数
      @supplier.tel02 = "1" * 7
      @supplier.should_not be_valid
      @supplier.tel02 = "1" * 6
      @supplier.should be_valid
    end      
    it "電話番号3" do
      #必須
      @supplier.tel03 = nil
      @supplier.should_not be_valid
      #数字
      @supplier.tel03 = "aaa"
      @supplier.should_not be_valid
      #桁数
      @supplier.tel03 = "1" * 7
      @supplier.should_not be_valid
      @supplier.tel03 = "1" * 6
      @supplier.should be_valid
    end
    it "郵便番号（前半）" do
      #必須
      @supplier.zipcode01 = nil
      @supplier.should_not be_valid
      #数字
      @supplier.zipcode01 = "aaa"
      @supplier.should_not be_valid
      #桁数
      @supplier.zipcode01 = "1034"
      @supplier.should_not be_valid
      @supplier.zipcode01 = "103"
      @supplier.should be_valid           
    end
    it "郵便番号（後半）" do
      #必須
      @supplier.zipcode02 = nil
      @supplier.should_not be_valid
      #数字
      @supplier.zipcode02 = "aaa"
      @supplier.should_not be_valid
      #桁数
      @supplier.zipcode02 = "001"
      @supplier.should_not be_valid
      @supplier.zipcode02 = "0001"
      @supplier.should be_valid         
    end
    it "FAX番号" do
      #数字
      @supplier.fax01 = 'abc'
      @supplier.fax02 = 'defg'
      @supplier.fax03 = 'hijk'
      @supplier.should have(1).errors_on(:fax01)
      @supplier.should have(1).errors_on(:fax02)
      @supplier.should have(1).errors_on(:fax03)
      #入力の場合、3か所とも
      @supplier.fax01 = nil
      @supplier.fax02 = '1111'
      @supplier.fax03 = '2222'
      @supplier.should_not be_valid
    end    
    it "メールアドレス" do
      #フォーマット
      @supplier.email = "aaa"
      @supplier.should_not be_valid
    end
    it "備考" do
      #桁数
      @supplier.free_comment = "a" * 10000
      @supplier.should be_valid
      @supplier.free_comment = "a" * 10001
      @supplier.should_not be_valid
    end
    it "商品かけ率" do
      @supplier.percentage = 101
      @supplier.should_not be_valid
      @supplier.percentage = "aaa"
      @supplier.should_not be_valid
      @supplier.percentage = -1
      @supplier.should_not be_valid
      @supplier.percentage = 0
      @supplier.should be_valid
      @supplier.percentage = 100
      @supplier.should be_valid
    end
    it "税額端数処理" do
      @supplier.tax_rule = 3
      @supplier.should_not be_valid
      @supplier.tax_rule = "aaa"
      @supplier.should_not be_valid
      @supplier.tax_rule = -1
      @supplier.should_not be_valid
      @supplier.tax_rule = 0
      @supplier.should be_valid
      @supplier.tax_rule = 2
      @supplier.should be_valid
    end    
    it "販売元" do
      @supplier.retailer_id = nil
      @supplier.should_not be_valid
      retailer_max = Retailer.find(:last).id + 100
      @supplier.retailer_id = retailer_max
      @supplier.should_not be_valid
      @supplier.retailer_id = Retailer::DEFAULT_ID
      @supplier.should be_valid      
    end
  end
  describe "その他" do
    fixtures :prefectures
    it "都道県府名" do
      supplier = Supplier.new(:prefecture_id =>11)
      supplier.prefecture_name.should == prefectures(:prefecture_00011).name
    end
  end

  describe "販売元一覧メソッド" do
    fixtures :admin_users

    it "引数なしの場合はDEFAILT_IDで検索" do 
      suppliers = Supplier.list_by_retailer
      suppliers.size.should == 4
    end
    it "検索が正常にできる(マスターショップ)" do 
      admin_user = admin_users(:load_by_admin_user_test_id_1)
      suppliers = Supplier.list_by_retailer(admin_user.retailer_id)
      suppliers.size.should == 4
    end

    it "検索が正常にできる(マスター以外のショップ)" do 
      admin_user = admin_users(:admin18_retailer_id_is_another_shop)
      suppliers = Supplier.list_by_retailer(admin_user.retailer_id)
      suppliers.size.should == 2
    end

  end
end
