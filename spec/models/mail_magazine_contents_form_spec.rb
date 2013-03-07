# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailMagazineContentsForm do
  before(:each) do
    @mail_maga_contents_form = MailMagazineContentsForm.new(:subject=>"メールマガコンテンツ",:body=>"メールマガコンテンツ本文です")
  end
  describe "validateチェック" do
    it "データが正しい" do
      @mail_maga_contents_form.should be_valid
    end
    it "タイトル" do
      #必須チェック
      @mail_maga_contents_form.subject = nil
      @mail_maga_contents_form.should_not be_valid
      #文字数チェック(256文字以下)
      @mail_maga_contents_form.subject = "あ" * 256
      @mail_maga_contents_form.should be_valid
      @mail_maga_contents_form.subject = "a" * 257
      @mail_maga_contents_form.should_not be_valid
    end
    it "本文" do
      #必須チェック
      @mail_maga_contents_form.body = nil
      @mail_maga_contents_form.should_not be_valid
      #文字数チェック(5120文字以下)
      @mail_maga_contents_form.body = "あ" * 5120
      @mail_maga_contents_form.should be_valid
      @mail_maga_contents_form.body = "a" * 5121
      @mail_maga_contents_form.should_not be_valid      
    end
  end
end
