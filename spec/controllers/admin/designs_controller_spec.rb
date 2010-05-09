require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::DesignsController do
  fixtures :designs
  fixtures :authorities, :functions, :admin_users
  before(:each) do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :master_shop_check
    #session[:admin_user] = admin_users(:admin_user_00011)
  end
  
  it "should use Admin::DesignController" do
    controller.should be_an_instance_of(Admin::DesignsController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should redirect_to(:controller=>"admin/designs", :action=>:pc)
    end

    it "マスターショップ以外はアクセスできない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end

  end

  describe "GET 'pc'" do
    it "should be successful" do
      get 'pc'
      assigns[:design].should_not be_nil
      response.should be_success
      response.should render_template("admin/designs/pc.html.erb")
    end
  end

  describe "GET 'update_pc'" do
    it "should be successful" do
      get 'update_pc', :id => 1, :design=>{:pc1 => "pc1"}
      response.should redirect_to(:controller=>"admin/designs", :action=>:pc)
    end
    it "validate error" do
      get 'update_pc', :design=>{:pc1=>"a" * (ActiveRecordValidate::TEXT_MAX_LENGTH + 1)}
      response.should render_template("admin/designs/pc.html.erb")
    end
  end

  describe "GET 'mobile'" do
    it "should be successful" do
      get 'mobile'
      response.should be_success
      response.should render_template("admin/designs/mobile.html.erb")
    end
  end

  describe "POST 'update_mobile'" do
    it "should be successful" do
      post 'update_mobile', :design => {:mobile1 => "mobile1"}
      response.should redirect_to(:action => :mobile)
    end
    it "validate error" do
      get 'update_mobile', :design=>{:mobile1=>"a" * (ActiveRecordValidate::TEXT_MAX_LENGTH + 1)}
      response.should redirect_to(:action => :mobile)
    end
  end
  
end


