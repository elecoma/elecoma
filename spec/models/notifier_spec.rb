# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do
  fixtures :shops, :customers, :inquiries,:mail_templates
  fixtures :orders, :order_deliveries, :order_details, :payments, :prefectures
  before(:each) do
    @shop = Shop.find(:first)
  end

  it "メールの送信に成功すること" do
    lambda {
      inquiry = inquiries(:inquiry_test_id_1)
      Notifier.deliver_pc_inquiry(inquiry)
    }.should_not raise_error
  end

  it "PCお問い合わせメール" do
    inquiry = inquiries(:inquiry_test_id_1)
    notifier = Notifier.create_pc_inquiry(inquiry)
    notifier.subject.toutf8.should == mail_templates(:template3).title
    notifier.to.should == [inquiry.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(inquiry.body).should_not be_nil
  end

  it "MBお問い合わせメール" do
    inquiry = inquiries(:inquiry_test_id_1)
    notifier = Notifier.create_mobile_inquiry(inquiry)
    notifier.subject.toutf8.should == mail_templates(:template3).title
    notifier.to.should == [inquiry.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(inquiry.body).should_not be_nil
  end

  it "管理者にお問い合わせメールがあることを通知メール" do
    inquiry = inquiries(:inquiry_test_id_1)
    notifier = Notifier.create_received_inquiry(inquiry,false)
    notifier.subject.toutf8.should =~ /お問い合わせがありました/
    notifier.to.should == [@shop.mail_faq]
    notifier.from.should == [inquiry.email]
    notifier.body.toutf8.index(inquiry.body).should_not be_nil
  end

  it "PCパスワード再発行のお知らせ" do
    customer = customers(:reminder_customer)
    new_ps = Customer.encode_password("111111")
    notifier = Notifier.create_reminder(customer, new_ps)    
    notifier.subject.toutf8.should == mail_templates(:template4).title
    notifier.to.should == [customer.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(new_ps).should_not be_nil
  end

  it "MBパスワード再発行のお知らせ" do
    customer = customers(:have_mobile_email_customer)
    new_ps = Customer.encode_password("111111")
    notifier = Notifier.create_mobile_reminder(customer, new_ps)
    notifier.subject.toutf8.should == mail_templates(:template4).title
    notifier.to.should == [customer.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(new_ps).should_not be_nil
  end

  it "会員アクティブメール" do
    customer = customers(:reminder_customer)
    url = "http://activation.com"
    notifier = Notifier.create_activate(customer, url)
    notifier.subject.toutf8.should == mail_templates(:template1).title
    notifier.to.should == [customer.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(url).should_not be_nil
  end

  it "注文完了メール" do
    order = orders(:customer_buy_two)
    notifier = Notifier.create_buying_complete(order)    
    notifier.subject.toutf8.should == mail_templates(:template2).title
    notifier.to.should == [order.order_deliveries[0].email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(order.code).should_not be_nil    
  end
  it "メールマガ（テキストメール）" do
    customer = customers(:reminder_customer)
    subject = "テストコードです（テキスト）"
    replace = "\{name\}"
    #body = "メールマガ（テキストメール）"
    body = "This is test mail (TEXT) "
    notifier = Notifier.create_text_mailmagazine(customer,(replace+body),subject)
    notifier.subject.toutf8.should == subject
    notifier.to.should == [customer.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(customer.full_name + body).should_not be_nil    
  end
  it "メールマガ（HTMLメール）" do
    customer = customers(:reminder_customer)
    subject = "テストコードです（HTML）"
    replace = "\{name\}"
    #body = "メールマガ（HTMLメール）"
    body = "This is test mail (HTML) "
    notifier = Notifier.create_html_mailmagazine(customer,(replace+body.toutf8),subject)
    notifier.subject.toutf8.should == subject
    notifier.to.should == [customer.email]
    notifier.from.should == [@shop.mail_sender]
    notifier.body.toutf8.index(customer.full_name + body).should_not be_nil    
  end  
end
