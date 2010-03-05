# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe System do
  fixtures :systems
  before(:each) do
    @system = systems(:load_by_system_test_id_1)
  end
  describe "validateチェック" do
    it "データがただしい" do
      systems(:load_by_system_test_id_1).should be_valid
    end  
    it "複数のデータが登録できない" do
      system = System.new(@system.attributes)
      system.should_not be_valid
    end

    it "空のデータも登録できる" do
      System.delete_all!
      system = System.new
      system.should be_valid
    end
  end

  describe "Google Analytics対応のチェック" do
    it "同期非同期にはアカウント番号がないとエラー" do
      @system.googleanalytics_use_flag = true
      @system.googleanalytics_select_code = System::GA_SELECT_SYNCH
      @system.googleanalytics_account_num = ""
      @system.should_not be_valid
      @system.googleanalytics_account_num = "UA-00000-01"
      @system.should be_valid
    end

    it "手入力の場合はトラッキングコードがないとエラー" do
      @system.googleanalytics_use_flag = true
      @system.googleanalytics_select_code = System::GA_SELECT_MANUAL
      @system.tracking_code = nil
      @system.should_not be_valid
    end

  end
end
