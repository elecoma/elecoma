# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewInformation do
  fixtures :new_informations
  before(:each) do
    @new_information = new_informations(:success_validates)
  end
  
  describe "validateチェック" do
    it "データが正しい場合" do
      @new_information.should be_valid
    end
    it "表示日付" do
      #必須チェック
      @new_information.date = nil
      @new_information.should_not be_valid
    end
    it "タイトル" do
      #必須チェック
      @new_information.name = nil
      @new_information.should_not be_valid
    end
    it "本文" do
      #文字数チェック
      @new_information.body = "あ" * 300
      @new_information.should be_valid
      @new_information.body = "い" * 301
      @new_information.should_not be_valid
    end
    it "URL" do
      #フォーマットチェック
      @new_information.url = "abcde"
      @new_information.should_not be_valid
    end 
  end
end
