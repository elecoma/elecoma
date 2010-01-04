require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mail do
  fixtures :customers
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

  end
end

class DummySMTP
  def initialize(address, port = nil)
  end

  def send_message(message, from, to)
  end
end
