# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionnaireAnswer do
  fixtures :questionnaire_answers
  
  before(:each) do
    @questionnaire_answer = questionnaire_answers(:questionnaire_answer_id_1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @questionnaire_answer.should be_valid
    end
    it "顧客名（姓）" do
      #必須チェック
      @questionnaire_answer.customer_family_name = nil
      @questionnaire_answer.should_not be_valid
    end
    it "顧客名（名）" do
      #必須チェック
      @questionnaire_answer.customer_first_name = nil
      @questionnaire_answer.should_not be_valid
    end
    it "顧客名（姓（カナ））" do
      #必須チェック
      @questionnaire_answer.customer_family_name_kana = nil
      @questionnaire_answer.should_not be_valid
      #全角カタカナチェック
      @questionnaire_answer.customer_family_name_kana = "あ"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.customer_family_name_kana = "ﾃｽﾄ"
      @questionnaire_answer.should_not be_valid
    end
    it "顧客名（名（カナ））" do
      #必須チェック
      @questionnaire_answer.customer_first_name_kana = nil
      @questionnaire_answer.should_not be_valid
      #全角カタカナチェック
      @questionnaire_answer.customer_first_name_kana = "あ"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.customer_first_name_kana = "ﾃｽﾄ"
      @questionnaire_answer.should_not be_valid
    end
    it "住所（市区町村）" do
      #必須チェック
      @questionnaire_answer.address_city = nil
      @questionnaire_answer.should_not be_valid      
    end
    it "住所（詳細）" do
      #必須チェック
      @questionnaire_answer.address_details = nil
      @questionnaire_answer.should_not be_valid      
    end
    it "電話番号1" do
      #必須チェック
      @questionnaire_answer.tel01 = nil
      @questionnaire_answer.should_not be_valid
      #数字チェック
      @questionnaire_answer.tel01 = "aa"
      @questionnaire_answer.should_not be_valid
    end
    it "電話番号2" do
      #必須チェック
      @questionnaire_answer.tel02 = nil
      @questionnaire_answer.should_not be_valid
      #数字チェック
      @questionnaire_answer.tel02 = "aa"
      @questionnaire_answer.should_not be_valid
    end
    it "電話番号3" do
      #必須チェック
      @questionnaire_answer.tel03 = nil
      @questionnaire_answer.should_not be_valid
      #数字チェック
      @questionnaire_answer.tel03 = "aa"
      @questionnaire_answer.should_not be_valid
    end
    it "メールアドレス" do
      #必須チェック
      @questionnaire_answer.email = nil
      @questionnaire_answer.should_not be_valid
      #フォーマット
      @questionnaire_answer.email = "@.com"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.email = ".com"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.email = "ａ@.com"
      @questionnaire_answer.should_not be_valid
    end
    it "郵便番号（前半）" do
      #必須チェック
      @questionnaire_answer.zipcode01 = nil
      @questionnaire_answer.should_not be_valid
      #数字チェック
      @questionnaire_answer.zipcode01 = "aa"
      @questionnaire_answer.should_not be_valid      
      #3桁
      @questionnaire_answer.zipcode01 = "1234"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.zipcode01 = "12"
      @questionnaire_answer.should_not be_valid
    end
    it "郵便番号（後半）" do
      #必須チェック
      @questionnaire_answer.zipcode02 = nil
      @questionnaire_answer.should_not be_valid
      #数字チェック
      @questionnaire_answer.zipcode02 = "aa"
      @questionnaire_answer.should_not be_valid      
      #4桁
      @questionnaire_answer.zipcode02 = "12345"
      @questionnaire_answer.should_not be_valid
      @questionnaire_answer.zipcode02 = "123"
      @questionnaire_answer.should_not be_valid
    end
  end
  
  describe "その他" do
    it "配列を戻る" do
      columns = ["id", "customer_family_name", "customer_first_name", "customer_family_name_kana", "customer_first_name_kana", "customer_id",
               "zipcode01", "zipcode02", "prefecture_name", "address_city", "address_details", "tel01", "tel02", "tel03","created_at", "email"]
      arr = []
      columns.each do |c|
        #更新時間について、
        #questionnaire_answer.created_atとquestionnaire_answer[created_at]の結果が違うので特別処理
        if "created_at" == c
          arr << (@questionnaire_answer.created_at.blank? ? nil : @questionnaire_answer.created_at.strftime('%Y-%m-%d %H:%M:%S'))
        else  
          arr << (@questionnaire_answer[c].blank? ? nil : @questionnaire_answer[c])
        end      
      end
      @questionnaire_answer.export_row.should == arr
    end  
  end
end
