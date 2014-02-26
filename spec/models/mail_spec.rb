# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'net/smtp'

describe Mail do
  fixtures :customers, :mails
  fixtures :prefectures

  before(:each) do
    @mails = Mail.new
  end

  it "should be valid" do
    @mails.should be_valid
  end

  describe "post_all_mail" do
    before(:each) do
      #Net::SMTP = DummySMTP
      @customer = customers(:valid_signup2)
      @dummysmtp = DummySMTP.new('localhost')
    end

    it "should be successful" do
      @dummysmtp.stub!(:send_message).and_return(nil)
      Net::SMTP.stub!(:start).and_yield(@dummysmtp)
      @mail = Mail.new(:to_address => @customer.email,
                       :from_address => "sender@example.com",
                       :message => "")
      @mail.save
      mails = Mail.find(:all, :conditions => "sent_at is null")
      mails.should_not == []
      Mail.post_all_mail
      mails = Mail.find(:all, :conditions => "sent_at is null")
      mails.should == []
    end

    it "raise 5xx error" do
      @customer.reachable.should be_true
      @dummysmtp.stub!(:send_message).and_raise(Net::SMTPSyntaxError)
      Net::SMTP.stub!(:start).and_yield(@dummysmtp)
      @mail = Mail.new(:to_address => @customer.email,
                       :from_address => "sender@example.com",
                       :message => "")
      @mail.save
      Mail.post_all_mail
      customer = Customer.find(@customer.id)
      customer.reachable.should be_false
    end

    it "raise 4xx error" do
      mail_delivery_count = @customer.mail_delivery_count
      mail_delivery_count = 1 if mail_delivery_count.nil?
      @dummysmtp.stub!(:send_message).and_raise(Net::SMTPServerBusy)
      Net::SMTP.stub!(:start).and_yield(@dummysmtp)
      @mail = Mail.new(:to_address => @customer.email,
                       :from_address => "sender@example.com",
                       :message => "")
      @mail.save
      Mail.post_all_mail
      customer = Customer.find(@customer.id)
      customer.reachable.should be_true
      customer.mail_delivery_count.should == mail_delivery_count + 1
    end

    it "over mail_delivery count" do
      @customer.mail_delivery_count = 5
      @customer.save
      @dummysmtp.stub!(:send_message).and_raise(Net::SMTPServerBusy)
      Net::SMTP.stub!(:start).and_yield(@dummysmtp)
      @mail = Mail.new(:to_address => @customer.email,
                       :from_address => "sender@example.com",
                       :message => "")
      @mail.save
      Mail.post_all_mail
      customer = Customer.find(@customer.id)
      customer.reachable.should be_false
    end

    describe "メールマガジン" do
      let (:now) { Time.parse('2014-02-26') }
      let (:schedule_case) { 10 }
      let (:mail_magazine) {
        MailMagazine.create(
          :schedule_case => schedule_case,
          :delivered_case => 0
        )
      }
      let (:mail) {
        Mail.new(
          :to_address => @customer.email,
          :from_address => "sender@example.com",
          :message => "test",
          :mailmagazine_id => mail_magazine.id
        )
      }

      before do
        @dummysmtp.stub!(:send_message).and_raise(Net::SMTPServerBusy)
        Net::SMTP.stub!(:start).and_yield(@dummysmtp)
        Time.stub!(:now).and_return(now)
      end

      it "メール送信すると配信件数が増える" do
        mail.save
        Mail.post_all_mail
        mail_magazine.reload.delivered_case.should > 0
      end

      it "予定件数分送信していない場合、配信終了時刻は空欄" do
        mail.save
        Mail.post_all_mail
        mail_magazine.reload.sent_end_at.should be_nil
      end

      it "予定件数分送信した場合、配信終了時刻に現在時刻が入る" do
        schedule_case.times { mail.clone.save }
        Mail.post_all_mail
        mail_magazine.reload.sent_end_at.should == now
      end
    end
  end
end

class DummySMTP
  def initialize(address, port = nil)
  end

  def send_message(message, from, to)
  end
end
