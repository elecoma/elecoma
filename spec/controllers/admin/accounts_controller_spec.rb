# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AccountsController do
  fixtures :admin_users

  before do
    @controller.class.before_filter :load_system
  end

  #Delete these examples and add some real ones
  it "should use Admin::AccountsController" do
    controller.should be_an_instance_of(Admin::AccountsController)
  end

  describe "post 'login'" do
    it "should be successful" do
      post 'login'
      response.should be_success
    end
  end

  describe "GET 'login'" do
    it "should be successful" do
      get 'login'
      response.should be_success
    end
  end

  describe "GET 'logout'" do
    it "should be successful" do
      get 'logout'
      response.should redirect_to(:controller=>"admin/accounts", :action=>"login")
    end
  end

  describe "ログイン処理" do
    it "ログインに成功するケース" do
      post 'login', :admin_user => {:login_id => 'admin1', :password => 'hoge'}
      flash[:notice].should be_nil
      response.should redirect_to(:controller=>"admin/home", :action=>"index")
      session[:admin_user].should == admin_users(:load_by_admin_user_test_id_1)
    end

    it "ログインに失敗するケース" do
      post 'login', :admin_users => {:login_id => 'admin1', :password => 'hoge'}
      response.should be_success
    end
  end

  describe "ログイン->ログアウト" do
    it "セッションデータの確認" do
      post 'login', :admin_user => {:login_id => 'admin1', :password => 'hoge'}
      session[:admin_user].should_not be_nil
      get 'logout'
      session[:admin_user].should be_nil
    end
  end
end
