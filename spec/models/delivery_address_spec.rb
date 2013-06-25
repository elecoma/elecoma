# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe DeliveryAddress do
  fixtures :delivery_addresses, :zips
  fixtures :prefectures

  before(:each) do
    @valid_address = delivery_addresses(:valid_address)
    @unvalid_address = delivery_addresses(:unvalid_address)
  end
  
  describe"validateチェック" do
    
    it "should be valid" do
      @valid_address.should be_valid
    end
    
    it "should not be valid" do
      @unvalid_address.should_not be_valid
    end

    describe "お届け先は" do
     
      before(:each) do
       (DeliveryAddress::MAXIMUM_POSITION - @valid_address.customer.delivery_addresses.count).times do
          @valid_address.clone.save
        end
      end

      it "#{DeliveryAddress::MAXIMUM_POSITION}件登録できている" do
        @valid_address.customer.delivery_addresses.count.should == DeliveryAddress::MAXIMUM_POSITION
      end

      it "#{DeliveryAddress::MAXIMUM_POSITION}件以上登録できない" do
        @valid_address.clone.save.should be_false
      end

      it "#{DeliveryAddress::MAXIMUM_POSITION}件登録してあるときでも変更できる" do
        @valid_address.family_name_kana = 'テスト'
        @valid_address.save.should be_true
      end
    end

    it "名: 必須" do
      @valid_address.first_name = nil
      @valid_address.should_not be_valid
    end
    
    it "姓(カナ): 必須" do
      @valid_address.family_name_kana = nil
      @valid_address.should_not be_valid
    end
    
    it "名(カナ): 必須" do
      @valid_address.first_name_kana = nil
      @valid_address.should_not be_valid
    end
    
    it "姓(カナ): カタカナのみ" do
      @valid_address.family_name_kana = 'ー'
      @valid_address.should be_valid
      @valid_address.family_name_kana = 'あああ'
      @valid_address.should_not be_valid
      @valid_address.family_name_kana = 'aaa'
      @valid_address.should_not be_valid
      @valid_address.family_name_kana = '999222'
      @valid_address.should_not be_valid
    end
    
    it "名(カナ): カタカナのみ" do
      @valid_address.first_name_kana = 'ー'
      @valid_address.should be_valid
      @valid_address.first_name_kana = 'いいい'
      @valid_address.should_not be_valid
      @valid_address.first_name_kana = 'iii'
      @valid_address.should_not be_valid
      @valid_address.first_name_kana = '999222'
      @valid_address.should_not be_valid
    end
    
    it "郵便番号1: 必須" do
      @valid_address.zipcode01 = nil
      @valid_address.should_not be_valid
    end
    
    it "郵便番号2: 必須" do
      @valid_address.zipcode02 = nil
      @valid_address.should_not be_valid
    end
    
    it "郵便番号1: 数字のみ" do
      @valid_address.zipcode01 = 'あ'
      @valid_address.should_not be_valid
    end
    
    it "郵便番号2: 数字のみ" do
      @valid_address.zipcode02 = 'い'
      @valid_address.should_not be_valid
    end
    
    it "郵便番号1: 3 文字固定" do
      @valid_address.zipcode01 = '12'
      @valid_address.should_not be_valid
      @valid_address.zipcode01 = '123'
      @valid_address.should be_valid
      @valid_address.zipcode01 = '1234'
      @valid_address.should_not be_valid
    end
    
    it "郵便番号2: 4 文字固定" do
      @valid_address.zipcode02 = '123'
      @valid_address.should_not be_valid
      @valid_address.zipcode02 = '1234'
      @valid_address.should be_valid
      @valid_address.zipcode02 = '12345'
      @valid_address.should_not be_valid
    end
    
    it "都道府県: 必須" do
      @valid_address.prefecture_id = nil
      @valid_address.should_not be_valid
    end
    
    it "都道府県：　数字のみ" do
      @valid_address.prefecture_id = 'う'
      @valid_address.should_not be_valid
    end

    it "都道府県：　範囲外" do
      @valid_address.prefecture_id = 48
      @valid_address.should_not be_valid
    end
    
    it "住所1: 必須" do
      @valid_address.address_city = nil
      @valid_address.should_not be_valid
    end
    
    it "住所2: 必須" do
      @valid_address.address_detail = nil
      @valid_address.should_not be_valid
    end
    
    it "対象のカラム以外のエラーは無視する" do
      @unvalid_address.should_not be_valid
      @unvalid_address.target_columns = []
      @unvalid_address.should be_valid
       columns = ["first_name","tel01"]
      @unvalid_address.target_columns = columns
      @unvalid_address.should_not be_valid
       after_columns = []
      @unvalid_address.errors.each do |i,j|
         after_columns << i
      end
       after_columns.should =~ columns
    end
    
  end
  
  it "郵便番号から住所を取ってくる" do
    address = DeliveryAddress.new()
    zip = zips(:zip_test_id_1)
    address.zipcode01 = zip.zipcode01
    address.zipcode02 = zip.zipcode02
    address.update_address!
    address.prefecture_id.should == zip.prefecture_id
    address.address_city.should == zip.address_city
    address.address_detail.should == zip.address_details
  end
end
