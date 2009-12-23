require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InquiriesController do
  fixtures :inquiries, :mobile_devices


  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete this example and add some real ones
  it "should use InquiriesController" do
    controller.should be_an_instance_of(InquiriesController)
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      assigns[:inquiry].kind.should == Inquiry::GOODS
      response.should be_success
    end

    it "should be successful(mobileでdocomoの場合)" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'new'
      assigns[:inquiry].email.should == "@docomo.ne.jp"
      response.should be_success
    end

    it "should be successful(mobileでauの場合)" do
      request.user_agent = "KDDI-SH36 UP.Browser/6.2.0.5"
      get 'new'
      assigns[:inquiry].email.should == "@ezweb.ne.jp"
      assigns[:inquiry].kind.should == Inquiry::GOODS
      response.should be_success
    end

    it "should be successful(mobileでsoftbankの場合)" do
      request.user_agent = "SoftBank/1.0/910T/TJ001/SN123456789012345 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      get 'new'
      assigns[:inquiry].email.should be_nil
      response.should be_success
    end

  end

  describe "GET 'confirm'" do
    it "should be successful" do
      inquiry = inquiries(:inquiry_test_id_1)
      get 'confirm', :inquiry => inquiry.attributes
      response.should be_success
    end

    it "should be successful(mobileのsoftbankの場合)" do
      inquiry = inquiries(:inquiry_test_id_1).attributes
      inquiry["email"] = "test"
      inquiry["email_user"] = "test"
      inquiry["email_domain"] = "softbank.ne.jp"
      request.user_agent = "SoftBank/1.0/910T/TJ001/SN123456789012345 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      get 'confirm', :inquiry => inquiry, :email_domain => "softbank.ne.jp"
      assigns[:inquiry].email.should == "test@softbank.ne.jp"
      response.should be_success
    end
  end

  it "newに戻る場合（validateに引っかかる）" do
    inquiry = inquiries(:inquiry_test_id_1)
    inquiry.name = ""
    get 'confirm', :inquiry => inquiry.attributes
    response.should render_template("inquiries/new.html.erb")
  end

  describe "GET 'complete'" do
    it "should be successful" do
    inquiry = inquiries(:inquiry_test_id_1)
      get 'complete', :inquiry => inquiry.attributes
      response.should be_success
    end
  end

  it "newに戻る場合（validateに引っかかる）" do
    inquiry = inquiries(:inquiry_test_id_1)
    inquiry.name = ""
    get 'complete', :inquiry => inquiry.attributes
    response.should render_template("inquiries/new.html.erb")
  end

  it "newに戻る場合（validateに引っかかる）(mobile)" do
    inquiry = inquiries(:inquiry_test_id_1)
    inquiry.name = ""
    get 'complete', :inquiry => inquiry.attributes
    response.should render_template("inquiries/new.html.erb")
  end

  it "お問い合わせが完了する場合" do
    Notifier.stub!(:deliver_pc_inquiry).and_return(nil)
    Notifier.stub!(:deliver_received_inquiry).and_return(nil)
    old_date_num = Inquiry.count
    inquiry = inquiries(:inquiry_test_id_1)
    get 'complete', :inquiry => inquiry.attributes
    Inquiry.count.should == old_date_num + 1
  end

  it "お問い合わせが完了する場合(mobile)" do
    request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
    Notifier.stub!(:deliver_mobile_inquiry).and_return(nil)
    Notifier.stub!(:deliver_received_inquiry).and_return(nil)
    old_date_num = Inquiry.count
    inquiry = inquiries(:inquiry_test_id_1)
    get 'complete', :inquiry => inquiry.attributes
    Inquiry.count.should == old_date_num + 1
  end

  describe "GET 'show'" do

    it "携帯からはshowページが表示" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'show'
      response.should be_success
      response.should render_template("inquiries/show_mobile.html.erb")
      assigns[:shop].should_not be_nil
    end
  
    it "PCからはnewページが表示" do
      get 'show'
      response.should be_success
      response.should render_template("inquiries/show.html.erb")
      assigns[:shop].should_not be_nil
    end
  end
end
