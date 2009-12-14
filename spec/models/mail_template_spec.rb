require File.dirname(__FILE__) + '/../spec_helper'

describe MailTemplate do
   fixtures :mail_templates
  before(:each) do
    @mail_template = mail_templates(:template1)
  end

  it "vaidate成功" do
    @mail_template.should be_valid
  end

  it "テンプレート 必須" do
    @mail_template.name = ""
    @mail_template.should_not be_valid
    @mail_template.name = "x"
    @mail_template.should be_valid
  end
  
  it "メールタイトル 必須" do
    @mail_template.title = ""
    @mail_template.should_not be_valid
    @mail_template.title = "x"
    @mail_template.should be_valid
  end
  
  it "ヘッダー 任意" do
    @mail_template.header = ""
    @mail_template.should be_valid
  end


  it "ヘッダー 3000 文字まで" do
    @mail_template.header = 'x' * 3000
    @mail_template.should be_valid
    @mail_template.header = 'x' * 3001
    @mail_template.should_not be_valid
  end

   it "フッター 任意" do
    @mail_template.header = ""
    @mail_template.should be_valid
  end


  it "フッター 3000 文字まで" do
    @mail_template.footer = 'x' * 3000
    @mail_template.should be_valid
    @mail_template.footer = 'x' * 3001
    @mail_template.should_not be_valid
  end
end
