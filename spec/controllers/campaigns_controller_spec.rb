# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe CampaignsController do
  fixtures :campaigns, :products, :customers, :systems

  before do
    session[:customer_id] = customers(:valid_signup).id
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end
  #Delete these examples and add some real ones
  it "should use CampaignsController" do
    controller.should be_an_instance_of(CampaignsController)
  end

  describe "GET 'show'" do
    it "should be successful" do
      campaign = campaigns(:open_campaign)
      get 'show', :dir_name => campaign.dir_name
      flash[:error].should be_nil
      assigns[:campaign_name].should == campaign.name
      assigns[:product].should == campaign.product
      assigns[:free_spaces].should_not be_nil
      assigns[:free_space_names].length.should == 4
      response.should render_template("campaigns/show")
    end

    it "btype = mobile should be successful" do
      campaign = campaigns(:open_campaign)
      get 'show', :dir_name => campaign.dir_name, :btype => "mobile"
      flash[:error].should be_nil
      assigns[:campaign_name].should == campaign.name
      assigns[:product].should == campaign.product
      assigns[:free_spaces].should_not be_nil
      assigns[:free_space_names].length.should == 3
      response.should render_template("campaigns/show")
    end

    it "mobile should be successful" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)"
      campaign = campaigns(:open_campaign)
      get 'show', :dir_name => campaign.dir_name
      flash[:error].should be_nil
      assigns[:campaign_name].should == campaign.name
      assigns[:product].should == campaign.product
      assigns[:free_spaces].should_not be_nil
      assigns[:free_space_names].length.should == 3
      response.should render_template("campaigns/show_mobile")
    end
  end

  describe "GET 'complete'" do
    it "通常のアンケート更新のケース" do
      campaign = campaigns(:open_campaign)
      get 'complete', :id => campaign.id
    end

    it "すでに応募されているケース" do
      campaign = campaigns(:open_campaign)
      customer = customers(:valid_signup)
      campaign.customers << customer && campaign.save
      get 'complete', :id => campaign.id
    end

    it "応募枠を越えたケース" do
      campaign = campaigns(:campaign_00004)
      campaign.application_count = campaign.max_application_number
      get 'complete', :id => campaign.id
    end

  end

#
#  describe "GET 'show'" do
#    it "should be successful" do
#      get 'show'
#      response.should be_success
#    end
#  end
#
#  it "キャンペーンが公開前の場合" do
#    get 'show', :dir_name => "not_open_campaign"
#    assigns[:campaign].should be_nil
#    flash[:notice].should == "該当するキャンペーンがありません"
#    response.should be_success
#  end
#
#  it "キャンペーンが公開中の場合" do
#    get 'show', :dir_name => "open_campaign"
#    assigns[:content].should == campaigns(:open_campaign).open_content
#    assigns[:header].should == campaigns(:open_campaign).open_header
#    assigns[:footer].should == campaigns(:open_campaign).open_footer
#    response.should be_success
#  end
#
#  it "キャンペーンが終了している場合" do
#    get 'show', :dir_name => "end_canpaign"
#    assigns[:content].should == campaigns(:end_campaign).end_content
#    assigns[:header].should == campaigns(:end_campaign).end_header
#    assigns[:footer].should == campaigns(:end_campaign).end_footer
#    response.should be_success
#  end
#
#  it "キャンペーンが存在しない場合" do
#    get 'show', :dir_name => "dummy"
#    assigns[:campaign].should be_nil
#    flash[:notice].should == "該当するキャンペーンがありません"
#    response.should be_success
#  end
end
