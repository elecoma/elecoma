# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AuthoritiesController do
  fixtures :authorities, :functions, :admin_users, :authorities_functions

  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end
  
  #Delete this example and add some real ones
  it "should use Admin::AuthoritiesController" do
    controller.should be_an_instance_of(Admin::AuthoritiesController)
  end

  describe "GET 'index'" do
    it "成功する" do
      get 'index'
      assigns[:authorities].should_not be_nil
    end
  end

  describe "GET 'edit'" do
    it "成功するパターン" do
      get 'edit', :id => 1
      assigns[:authority].should_not be_nil
      assigns[:authority].id.should == 1
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 10000 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end 

  describe "GET 'new'" do
    it "成功" do
      get 'new'
      assigns[:authority].should_not be_nil
      assigns[:authority].id.should be_nil
    end
  end

  describe "POST 'create'" do
    it "正常に追加できるパターン" do
      get 'new'
      authority = {:name => "管理者2"}
      functions = {"1" => 1, "2" => 2}
      post 'create', :authority => authority, :functions => functions
      assigns[:authority].should_not be_nil
      #assigns[:authority].id.should == new_id
      check = Authority.find(:last)
      check.name.should == "管理者2"
      response.should redirect_to(:action => :index)
    end

    it "authorityが不正なパターン" do
      get 'new'
      authority = {:name => ""}
      functions = {"1" => 1, "2" => 2}
      post 'create', :authority => authority, :functions => functions
      assigns[:authority].should_not be_nil
      assigns[:authority].id.should be_nil
      response.should_not be_redirect
      response.should render_template("admin/authorities/new.html.erb")
    end

    it "functionsが不正なパターン" do
      get 'new'
      authority = {:name => "管理者2"}
      functions = {"test" => 1, "2" => 2}
      lambda { post 'create', :authority => authority, :functions => functions }.should raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe "POST 'update'" do
    it "正常に更新できるパターン" do
      authority = {:name => "管理者2", :id => 1, :position => 1}
      functions = {"1" => 1, "2" => 2}
      post 'update', :id => 1, :authority => authority, :functions => functions
      assigns[:authority].id.should == 1
      check = Authority.find_by_id(1)
      check.name.should == "管理者2"
      response.should redirect_to(:action => :index)
    end

    it "更新に失敗するパターン1" do
      authority = {:name => ""}
      name = Authority.find_by_id(1).name
      functions = {"1" => 1, "2" => 2}
      post 'update', :id => 1, :authority => authority, :functions => functions
      check = Authority.find_by_id(1)
      check.name.should == name
      response.should render_template("admin/authorities/edit.html.erb")
    end
      
  end

  describe "GET 'up'" do
    it "正常に更新できるパターン" do
      get 'up', :id => 3
      check1 = Authority.find_by_id(3)
      check1.position.should == 2
      check2 = Authority.find_by_id(2)
      check2.position.should == 3
    end
  end

  describe "GET 'down'" do
    it "正常に更新できるパターン" do
      get 'down', :id => 3
      check1 = Authority.find_by_id(3)
      check1.position.should == 4
      check2 = Authority.find_by_id(4)
      check2.position.should == 3
    end
  end

end
