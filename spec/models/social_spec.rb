# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Social do

  fixtures :socials
  before do
    @social = socials(:one)
  end

  describe "validateチェック" do
    it "初期状態" do
      social = Social.new
      social.shop_id = 1
      social.should be_valid
    end

    it "Twitter名: 15文字制限チェック" do
      # 15文字以上はだめ
      @social.twitter_user = "a" * 15
      @social.should be_valid
      @social.twitter_user = "a" * 16
      @social.should_not be_valid
    end

    it "mixi: 説明文未入力" do
      @social.mixi_description = ""
      @social.should_not be_valid
    end

    it "mixi: チェックキー未入力" do
      @social.mixi_key = ""
      @social.should_not be_valid
    end

    it "mixi: チェックキーが60文字以上" do
      @social.mixi_key = "a" * 60
      @social.should be_valid
      @social.mixi_key = "a" * 61
      @social.should_not be_valid
    end

    it "mixi: チェックキーに不正な文字" do
      @social.mixi_key = "ada da"
      @social.should_not be_valid
    end
  end

end
