require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::MobileDevicesController do
  fixtures :mobile_devices, :authorities, :authorities_functions, :admin_users

  before(:each) do
    session[:admin_user] = admin_users(:load_by_admin_user_test_id_1)
    @controller.class.skip_before_filter :admin_permission_check_mobile
    #@controller.class.skip_after_filter @controller.class.after_filter
  end
    
  #Delete these examples and add some real ones
  it "should use Admin::MobileDevicesController" do
    controller.should be_an_instance_of(Admin::MobileDevicesController)
  end


  describe "GET 'index'" do
    it "idに正しいものを渡すと成功する" do
      get 'index', :id => 1
      assigns[:mobile_device].should == MobileDevice.find_by_id(1)
      assigns[:status].should == 'update'
      assigns[:method].should == 'put'
      response.should be_success
    end

    it "idに不正なものを渡すと失敗する" do
      lambda{get 'index', :id => 5000000}.should raise_error(NoMethodError)
    end

    it "idを渡さないと普通の動作となる" do
      get 'index'
      assigns[:mobile_device].id.should be_nil
      assigns[:status].should == 'create'
      assigns[:method].should == 'post'
      response.should be_success
    end
  end

  describe "get 'new'" do
    it "リダイレクトをする" do
      get 'new'
      response.should redirect_to(:action => 'index')
    end
  end

  describe "post update" do
    it "成功するパターン" do
      get 'edit', :id => 1
      assigns[:mobile_device].should_not be_nil
      mobile1 = assigns[:mobile_device]
      mobile1.user_agent = "P05%"
      post 'update', :mobile_device => {:mobile_carrier_id => mobile1.mobile_carrier_id, :device_name => mobile1.device_name, :user_agent => mobile1.user_agent, :width => mobile1.width, :height => mobile1.height}
      response.should redirect_to(:action => "index")
    end

    it "失敗するパターン" do
      get 'edit', :id => 1
      assigns[:mobile_device].should_not be_nil
      mobile1 = assigns[:mobile_device]
      mobile1.user_agent = "!!!!"
      post 'update', :mobile_device => {:mobile_carrier_id => mobile1.mobile_carrier_id, :device_name => mobile1.device_name, :user_agent => mobile1.user_agent, :width => mobile1.width, :height => mobile1.height}
      response.should_not redirect_to(:action => "index")
    end
  end

  describe "post create" do
    it "成功するパターン" do
      get 'new'
      post 'create', :mobile_device => {:mobile_carrier_id => 1, :device_name => "P-06A", :user_agent => "P06", :width => 240, :height => 320}
      response.should redirect_to(:action => 'index')
    end

    it "失敗するパターン" do
      get 'new'
      post 'create', :mobile_device => {:mobile_carrier_id => 1, :device_name => "P-06A", :user_agent => "P!!P", :width => 240, :height => 320}
      response.should_not redirect_to(:action => 'index')
    end
  end

  describe "search" do
    it "一件データがある場合" do
      get 'search', :search => {:user_agent => "P05" }
      assigns[:mobile_devices].should_not be_nil
    end
  end

  describe "get destroy" do
    it "成功するパターン" do
      MobileDevice.find_by_id(1).should_not be_nil
      get 'destroy', :id => 1
      MobileDevice.find_by_id(1).should be_nil
    end
    
    it "失敗するパターン" do
      lambda { get 'destroy', :id => 12132342 }.should raise_error(NoMethodError)
    end
  end

end
