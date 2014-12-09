# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe PortalController do
  fixtures :customers, :carts, :products, :categories, :new_informations, :recommend_products, :systems, :product_styles, :laws, :faqs, :retailers
  fixtures :shops

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use PortalController" do
    controller.should be_an_instance_of(PortalController)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end

  it "セッションにユーザーが無い時、ユーザーをロードしない事" do
    session[:customer_id] = nil
    get 'show'
    response.should be_success
    assigns[:login_user].should be_nil
  end

  it "セッションにユーザーが有る時、ユーザーをロードする事" do
    session[:customer_id] = customers(:login_customer).id
    get 'show'
    response.should be_success
    assigns[:login_customer].should_not be_nil
    assigns[:login_customer].should == customers(:login_customer)
  end

  it "セッションのカートをロードする" do
    set_carts = [ carts(:cart_by_have_cart_user_one), carts(:cart_by_have_cart_user_two)]
    session[:customer_id] = nil
    session[:carts] = set_carts.map(&:attributes)
    get 'show'
    response.should be_success
    assigns[:carts].size.should == set_carts.size
    assigns[:carts].zip(set_carts).each do |actual, expected|
      actual.product_style_id.should == expected.product_style_id
      actual.quantity.should == expected.quantity
    end
  end

  it "お知らせをロードする" do
    get 'show'
    response.should be_success
    assigns[:new_informations].size.should > 0
    assigns[:new_informations].should == NewInformation.find(:all, :order => "position") 
  end

  it "オススメ商品をロードする" do
    get 'show'
    response.should be_success
    assigns[:recommend_products].size.should > 0
    #assigns[:recommend_products].should == RecommendProduct.find(:all, :order => "position") 
    assigns[:recommend_products].should == RecommendProduct.find(:all, :conditions => ["product_order_unit_id>=? or description<>?", 1, ""], :order => "position") 
  end

  it "新着商品をロードする" do
    get 'show'
    response.should be_success
    assigns[:new_products].should_not be_nil
  end

  describe "GET 'show_tradelaw" do
    it "should be successful" do
      get 'show_tradelaw'
      assigns[:law].should_not be_nil
    end
  end

  describe "privacy" do
    it "should be successful" do
      get 'privacy'
      response.should render_template("portal/privacy")
    end
  end

  describe "GET 'first_one'" do
    it "should be successful" do
      request.user_agent = "DoCoMo/2.0 SH903i(c100;TB;W24H16)" 
      get 'first_one'
      response.should render_template("portal/first_one_mobile")
    end

    it "PC is 404" do
      get 'first_one'
      response.should render_template("public/404.html")
    end
  end

  describe "GET 'company'" do
    it "should be successful" do
      get 'company'
      response.should render_template("portal/company")
    end
  end

  describe "GET 'escape_clause'" do
    it "should be successful" do
      get 'escape_clause'
      response.should render_template("portal/escape_clause")
    end
  end

  describe "GET 'maintenance'" do
    it "should be successful" do
      get 'maintenance'
      response.should render_template("portal/maintenance")
    end
  end

  describe "GET 'notice'" do
    it "should be successful" do
      get 'notice'
      response.should render_template("portal/notice")
    end
  end

end
