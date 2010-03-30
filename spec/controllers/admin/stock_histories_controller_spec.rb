require 'spec_helper'

describe Admin::StockHistoriesController do

  fixtures :admin_users,:products,:product_styles,:suppliers, :stock_histories
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter    
  end

  #Delete this example and add some real ones
  it "should use Admin::StockHistoriesController" do
    controller.should be_an_instance_of(Admin::StockHistoriesController)
  end

  describe 'get search' do 
    it "all log" do 
      get 'search', :condition => {}
      assigns[:stock_histories].size.should > 0
    end

    it "is fail_retailer" do 
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      get 'search', :condition => {}
      assigns[:stock_histories].size.should == 0
    end
  end

end
