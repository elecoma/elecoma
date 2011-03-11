# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe RetailersController do
  fixtures :retailers, :shops

  before do
  end

  #Delete these examples and add some real ones
  it "should use RetailersController" do
    controller.should be_an_instance_of(RetailersController)
  end

  describe "GET 'index'" do 
    it "販売元ID = 2を表示" do 
      get 'index', :id => 2
      assigns[:retailer].should == retailers(:other_retailer_2)
    end

    it "販売元IDがDEFAULT_IDの場合は表示できない" do 
      get 'index', :id => Retailer::DEFAULT_ID
      response.should redirect_to(:controller => :portal, :action => :show)
    end

    it "販売元IDを渡さないと表示できない" do 
      get 'index'
      response.should redirect_to(:controller => :portal, :action => :show)
    end

    it "販売元IDが無効の場合は表示できない" do 
      get 'index', :id => 50000
      response.should redirect_to(:controller => :portal, :action => :show)
    end
  end


end
