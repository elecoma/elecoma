require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::RetailersController do
  fixtures :admin_users, :retailers

  before do
    @main_shop = admin_users(:load_by_admin_user_test_id_1)
    @sub_shop = admin_users(:admin18_retailer_id_is_another_shop)
  end

  it "should use Admin::RetailersController" do
    controller.should be_an_instance_of(Admin::RetailersController)
  end

  describe "GET 'index'" do
    it "メインショップはindexが見れる" do
      session[:admin_user] = @main_shop
      get 'index'
      response.should be_success
    end

    it "サブショップはindexにアクセスできない" do
      session[:admin_user] = @sub_shop
      get 'index'
      response.should redirect_to(:controller=>"admin/home", :action=>"index")
    end
  end
end
