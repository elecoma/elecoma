# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailMagazineTemplate do
  fixtures :mail_magazine_templates
  before(:each) do
    @mail_magazine_template = mail_magazine_templates(:valid_success)
  end
  describe "validateチェック" do
    it "vaidate成功" do
      @mail_magazine_template.should be_valid
    end
  
    it "メール形式 " do
      #必須チェック
      @mail_magazine_template.form = ""
      @mail_magazine_template.should_not be_valid
    end
  
    it "件名" do
      #必須チェック
      @mail_magazine_template.subject = ""
      @mail_magazine_template.should_not be_valid
      #文字数（300以下）
      @mail_magazine_template.subject = "あ" * 300
      @mail_magazine_template.should be_valid  
      @mail_magazine_template.subject = "a" * 301
      @mail_magazine_template.should_not be_valid
    end
    
    it "本文" do
      #必須チェック
      @mail_magazine_template.body = ""
      @mail_magazine_template.should_not be_valid
      #文字数(100000以下)      
      @mail_magazine_template.body = "あ"*100000
      @mail_magazine_template.should be_valid
      @mail_magazine_template.body = "a"*100001
      @mail_magazine_template.should_not be_valid      
    end
  end
  describe "表示系" do
    it "メール形式 " do
      @mail_magazine_template.get_form_name.should == MailMagazineTemplate::FORM_TYPE_NAMES[MailMagazineTemplate::TEXT]
      template = MailMagazineTemplate.new(:form=>MailMagazineTemplate::HTML)
      template.get_form_name.should == MailMagazineTemplate::FORM_TYPE_NAMES[MailMagazineTemplate::HTML]
    end    
  end
end
