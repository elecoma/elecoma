require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::LawsController do
  fixtures :authorities, :functions, :admin_users

  before(:each) do
    @controller.class.skip_before_filter @controller.class.before_filter
    @admin1 = admin_users(:load_by_admin_user_test_id_1)
    @admin2 = admin_users(:admin18_retailer_id_is_another_shop)
  end

  describe "GET 'index'" do
    describe "retailer_id = 1" do
      before(:each) do
        session[:admin_user] = @admin1
      end

      it "should be successful" do
        get 'index'
        response.should render_template("admin/laws/index")
      end
    end
   

  end

end
