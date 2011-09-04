# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::CampaignsController do
  fixtures :admin_users, :campaigns
  fixtures :products
  before(:each) do
    session[:admin_user] = admin_users(:admin_user_00011)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :design_init, :only => [:campaign_design, :campaign_design_update]
    @controller.class.before_filter :master_shop_check
  end

  #Delete these examples and add some real ones
  it "should use Admin::CampaignsController" do
    controller.should be_an_instance_of(Admin::CampaignsController)
  end


  describe "GET 'index'" do
    before do
      
    end
    
    it "should be successful" do
      get 'index'
      assigns[:campaigns].should_not be_nil
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      assigns[:campaign].should_not be_nil
      response.should be_success
    end
  end

  describe "POST'create'" do
    it "should be successful" do
      size = Campaign.find(:all).size
      campaign = {:name => "Test", :dir_name => "DirName"}
      campaign.merge! datetime_to_select(DateTime.now, 'opened_at')
      campaign.merge! datetime_to_select(DateTime.now, 'closed_at')
      post 'create', :campaign => campaign
      Campaign.find(:all).size.should == size + 1
      response.should redirect_to(:action => 'index')
    end
  end

  describe "POST 'update'" do
    it "should be successful" do
      campaign = {:name => "Test", :dir_name => "DirName"}
      post 'update', :id => 1, :campaign => campaign
      response.should redirect_to(:action => 'index')
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      Campaign.find_by_id(1).should_not be_nil
      get 'destroy', :id => 1
      Campaign.find_by_id(1).should be_nil
    end
  end

  describe "GET 'csv_download'" do
    it "should be successful" do
      get 'csv_download', :id => 1
      response.should be_success
    end

    it "CSV出力" do
      get 'csv_download', :id => 1
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
    end
    
    it "should raise error" do
      lambda { get 'csv_download', :id => 0 }.should raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe "POST 'campaign_design'" do
    it "type = open_pc" do
      get 'campaign_design', :id => 1, :type => "open_pc"
      assigns[:title].should_not be_nil
    end

    it "存在しないtypeを指定" do
      get 'campaign_design', :id => 1, :type => "not_found_type"
      assigns[:title].should be_nil
    end
  end

  describe "POST 'campaign_design_update'" do
    it "type = open_pc" do
      type = "open_pc"
      campaign = {:open_pc_free_space_1 => "freespace1",
        :open_pc_free_space_2 => "freespace2",
        :open_pc_free_space_3 => "freespace3",
        :open_pc_free_space_4 => "freespace4"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:action => "campaign_design", :id => 1, :type => type)
    end

    it "type = end_pc" do
      type = "end_pc"
      campaign = {:end_pc_free_space_1 => "freespace1",
        :end_pc_free_space_2 => "freespace2",
        :end_pc_free_space_3 => "freespace3",
        :end_pc_free_space_4 => "freespace4"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:action => "campaign_design", :id => 1, :type => type)
    end

    it "type = open_mobile" do
      type = "open_mobile"
      campaign = {:open_mobile_free_space_1 => "freespace1",
        :open_mobile_free_space_2 => "freespace2",
        :open_mobile_free_space_3 => "freespace3"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:action => "campaign_design", :id => 1, :type => type)
    end
    
    it "type = end_mobile" do
      type = "end_mobile"
      campaign = {:end_mobile_free_space_1 => "freespace1",
        :end_mobile_free_space_2 => "freespace2",
        :end_mobile_free_space_3 => "freespace3"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:action => "campaign_design", :id => 1, :type => type)
    end

    it "登録できない場合" do
      type = "open_mobile"
      campaign = {:open_mobile_free_space_1 => "a" * 1000000,
        :open_mobile_free_space_2 => "freespace2",
        :open_mobile_free_space_3 => "freespace3"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      flash[:notice].should be_nil
      response.should render_template("admin/campaigns/campaign_design.html.erb")
    end

  end

  describe "POST 'campaign_preview'" do
    it "type = open_pc" do
      type = "open_pc"
      campaign = {:open_pc_free_space_1 => "freespace1",
        :open_pc_free_space_2 => "freespace2",
        :open_pc_free_space_3 => "freespace3",
        :open_pc_free_space_4 => "freespace4"}
      post 'campaign_preview', :id => 1, :type => type, :campaign => campaign
      assigns[:free_spaces]["open_pc_free_space_1"].should == "freespace1"
      response.should render_template("campaigns/show")
    end

    it "type = end_pc" do
      type = "end_pc"
      campaign = {:end_pc_free_space_1 => "freespace1",
        :end_pc_free_space_2 => "freespace2",
        :end_pc_free_space_3 => "freespace3",
        :end_pc_free_space_4 => "freespace4"}
      post 'campaign_preview', :id => 1, :type => type, :campaign => campaign
      assigns[:free_spaces]["end_pc_free_space_1"].should == "freespace1"
      response.should render_template("campaigns/show")
    end

    it "type = open_mobile" do
      type = "open_mobile"
      campaign = {:open_mobile_free_space_1 => "freespace1",
        :open_mobile_free_space_2 => "freespace2",
        :open_mobile_free_space_3 => "freespace3"}
      post 'campaign_preview', :id => 1, :type => type, :campaign => campaign
      assigns[:free_spaces]["open_mobile_free_space_1"].should == "freespace1"
      response.should render_template("campaigns/show_mobile")
    end
    
    it "type = end_mobile" do
      type = "end_mobile"
      campaign = {:end_mobile_free_space_1 => "freespace1",
        :end_mobile_free_space_2 => "freespace2",
        :end_mobile_free_space_3 => "freespace3"}
      post 'campaign_preview', :id => 1, :type => type, :campaign => campaign
      assigns[:free_spaces]["end_mobile_free_space_1"].should == "freespace1"
      response.should render_template("campaigns/show_mobile")
    end
  end

  describe "マスターショップ以外はアクセスができない" do
    before do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
    end

    it "POST 'campaign_preview'" do
      type = "end_mobile"
      campaign = {:end_mobile_free_space_1 => "freespace1",
        :end_mobile_free_space_2 => "freespace2",
        :end_mobile_free_space_3 => "freespace3"}
      post 'campaign_preview', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:controller => "home", :action => "index")
    end

    it "POST 'campaign_design_update'" do
      type = "open_pc"
      campaign = {:open_pc_free_space_1 => "freespace1",
        :open_pc_free_space_2 => "freespace2",
        :open_pc_free_space_3 => "freespace3",
        :open_pc_free_space_4 => "freespace4"}
      post 'campaign_design_update', :id => 1, :type => type, :campaign => campaign
      response.should redirect_to(:controller => "home", :action => "index")
    end

    it "GET 'index'" do
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end
  end

end
