# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageResourceController do
  fixtures :image_resources, :resource_datas, :shops

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end
  #Delete this example and add some real ones
  it "should use ImageResourceController" do
    controller.should be_an_instance_of(ImageResourceController)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id => image_resources(:resource_00001).id
      response.should be_success
      response.headers["Content-Type"].should =~ %r(^image)
    end

    it "should be successful(filename)" do
      get 'show', :filename => image_resources(:resource_00001).name
      response.should be_success
      response.headers["Content-Type"].should =~ %r(^image)
    end

    it "画像を表示" do
      get 'show', :id => image_resources(:resource_00001).id
      response.body.should == image_resources(:resource_00001).view
    end

    it "画像を表示(mobile)" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      get 'show', :id => image_resources(:resource_00001).id
      response.body.should_not == image_resources(:resource_00001).view
    end

    it "should be not found" do
      #ActiveRecord::Base.connection.stub!(:rollback_db_transaction).and_return(nil)
      get 'show', :id =>0
      response.headers["Content-Type"].should =~ %r(text)
      response.body.should_not be_blank
    end
  end

  describe "GET 'thumbnail'" do
    it "should be successful" do
      get 'thumbnail'
      response.should be_success
    end
  end
end
