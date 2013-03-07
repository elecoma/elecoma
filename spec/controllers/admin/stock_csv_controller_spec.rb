# -*- coding: utf-8 -*-
require 'spec_helper'

describe Admin::StockCsvController do
  fixtures :admin_users,:products,:product_styles,:suppliers
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter    
  end

  #Delete this example and add some real ones
  it "should use Admin::StockCsvController" do
    controller.should be_an_instance_of(Admin::StockCsvController)
  end

  describe "csv" do 
    it "get csv" do 
      get 'csv', :id => "20100101"
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      rows = response.body.chomp.split("\n")
      rows.size.should >= 10
    end

    it "idが無ければ、csvは取得できない" do
      get 'csv'
      response.should render_template("public/404.html")
    end

    it "is retailer_fail" do 
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      get 'csv', :id => "20100101"
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      rows = response.body.chomp.split("\n")
      rows.size.should == 1      
    end
  end

end
