# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
class TestForm < SearchForm
  set_field_names({"customer_id" => "顧客コード"})
  set_field_names({"customer_name" => "顧客名"})
end
describe SearchForm do
  before(:each) do
    @attributes = {
      "name"  => "てすと",
      "name_kana"  => "テスト",
      "email" => "test@kbmj.com",
      "order_status" => 3, 
      "order_date_from" => DateTime.now,
      "order_date_to" => DateTime.now + 1.day
    }
    @search_form = SearchForm.new(@attributes)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @search_form.should be_valid
    end
    it "from/to" do
      #nilの場合、チェックを飛ばし
      new_attributes = @attributes.merge({"order_date_to" => nil})
      search_form = SearchForm.new(new_attributes)
      search_form.should be_valid
      #from > toの場合、エラーを出す
      new_attributes = @attributes.merge({"order_date_to" => DateTime.now - 1.day})
      search_form = SearchForm.new(new_attributes)
      search_form.should_not be_valid
    end
  end
  describe "属性" do  
    it "属性セット" do
      @search_form.attributes.should == @attributes
    end
    it "データセット(検索用年月日)" do
      search_form = SearchForm.new({"order_date_to" => "2009-10-01 00:30:45","month(1i)"=>"2009"})
      #期待結果：
      #1.文字列の時間系をdateへ変換 2.["month(1i)"=>"2009"]が [@month=Thu, 01 Jan 2009 00:00:00]に変換
      search_form.order_date_to.class.should == Time
      search_form.month.should_not be_nil
      search_form.month.should == Time.parse("2009-01-01 00:00:00")
    end
    it "その他" do
      TestForm.human_attribute_name("customer_id").should == "顧客コード"
      TestForm.field_names.should == {"customer_id" => "顧客コード","customer_name" => "顧客名"}
    end
  end
end
