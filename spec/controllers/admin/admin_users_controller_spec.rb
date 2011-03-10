# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AdminUsersController do
  fixtures :admin_users, :retailers

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete this example and add some real ones
  it "should use Admin::AdminUsersController" do
    controller.should be_an_instance_of(Admin::AdminUsersController)
  end

#  describe "GET 'list'" do
#    it "should be successful" do
#      get 'list', :model => "admin_user"
#      response.should be_success
#      assigns[:records].should == AdminUser.find(:all, :order => "position")
#    end
#  end

  describe "GET '新規登録画面'" do
    it "should be successful" do
      get 'new'
      response.should be_success
      assigns[:admin_user].should_not be_nil
    end
  end

  describe "GET '編集画面'" do
    it "編集データが取得できる" do
      get 'edit', :id => 1
      response.should be_success
      assigns[:admin_user].should == AdminUser.find(1)
    end

    it "編集データが取得できない" do
      lambda { get 'edit', :id => AdminUser.maximum(:id)+1 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
 
  describe "GET '新規登録'" do
    before do
      @record = AdminUser.new({:name=>"gundam", :login_id=>"zak", :password=>"hyakushiki", :authority_id => 1, :retailer_id => 1})
    end
    it "登録に成功する" do
      post 'create', :admin_user => @record.attributes
      create_record = AdminUser.find(AdminUser.maximum(:id))
      create_record.login_id.should == @record.login_id
      create_record.position.should == AdminUser.maximum(:position)
      #flash[:notice].should_not be_nil
      #response.should redirect_to(:action=>:new)
      response.should be_redirect
    end

   it "登録に失敗する" do
      @record.login_id = nil
      post 'create', :admin_user => @record.attributes
      AdminUser.find_by_id(AdminUser.maximum(:id)).login_id.should_not == "zak"
      #flash[:error].should_not be_nil
      response.should render_template("admin/admin_users/new")
   end
  end

  describe "GET '編集'" do
    before do
      @record = admin_users(:admin10)
    end
    it "編集に成功する" do
      @record.login_id = "zz"
      get 'update', :model => "admin_user", :id => @record.id, :record=>@record.attributes
      record = AdminUser.find_by_id(@record.id)
      record.password.should_not be_nil
      record.position.should == @record.position
      flash[:notice].should_not be_nil
      #response.should redirect_to(:action=>:new)
      response.should be_redirect
    end

    it "編集に失敗する" do
      login_id = @record.login_id
      @record.login_id = admin_users(:load_by_admin_user_activity_false).login_id
      get 'update', :model => "admin_user", :id => @record.id, :record=>@record.attributes
      AdminUser.find_by_id(@record.id).login_id.should == login_id
      #flash[:error].should_not be_nil      
      #response.should render_template("admin/admin_user/edit")
      response.should be_redirect
    end
  end

  describe "GET 'destroy'" do
    it "削除に成功する" do
      get 'destroy', :model => "admin_user", :id => 1
      flash[:notice].should_not be_nil
      AdminUser.find(:first,:order => "id").id.should == 2
      #response.should redirect_to(:action => "index", :model => "admin_user")
      response.should be_redirect
    end
  end

  it "削除に失敗する場合" do
    lambda { get 'destroy', :model => "admin_user", :id => 100 }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
  describe "GET 'up'" do
    it "should be successful" do
      get 'up', :model => "admin_user", :id => 1
      #response.should redirect_to(:action => "index", :model => "admin_user")
      response.should be_redirect
    end
  end

  it "positionを上げる場合" do
    AdminUser.find(1).position.should == 2
    #get 'sort', :model => "admin_user", :id => 1, :move => "up"
    get 'up', :model => "admin_user", :id => 1
    AdminUser.find(1).position.should == 1
    #response.should redirect_to(:action => "index", :model => "admin_user")
    response.should be_redirect
  end

  it "positionを上げる場合(これ以上あがらない)" do
    AdminUser.find(2).position.should == 1
    #get 'sort', :model => "admin_user", :id => 2, :move => "up"
    get 'up', :model => "admin_user", :id => 2
    AdminUser.find(2).position.should == 1
    #response.should redirect_to(:action => "index", :model => "admin_user")
    response.should be_redirect
  end


  it "positionを下げる場合" do
    AdminUser.find(2).position.should == 1
    #get 'sort', :model => "admin_user", :id => 2, :move => "down"
    get 'down', :model => "admin_user", :id => 2
    AdminUser.find(2).position.should == 2
    #response.should redirect_to(:action => "index", :model => "admin_user")
    response.should be_redirect
  end

  it "positionを下げる場合（これ以上下がらない）" do
    AdminUser.find(16).position.should == 106
    #get 'sort', :model => "admin_user", :id => 3, :move => "down"
    get 'down', :model => "admin_user", :id => 16
    AdminUser.find(16).position.should == 106
    #response.should redirect_to(:action => "index", :model => "admin_user")
    response.should be_redirect
  end

  describe "Get 'update_activity'" do
    it "稼働を非稼働に変更する" do
      record = admin_users(:load_by_admin_user_activity_true)
      record.activity.should == 1
      get 'update_activity', :id => record.id, :activity => "false"
      AdminUser.find(record.id).activity.should == 0
    end

    it "非稼働を稼働に変更する" do
      record = admin_users(:load_by_admin_user_activity_false)
      record.activity.should == 0
      get 'update_activity', :id => record.id, :activity => "true"
      AdminUser.find(record.id).activity.should == 1
    end
  end

  describe "マスターショップ以外のチェック" do
    before do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
    end
    
    it "GET 'index'" do
      get 'index'
      assigns[:admin_users].length.should == 1
      assigns[:admin_users][0].should == admin_users(:admin18_retailer_id_is_another_shop)
    end
 
    it "編集データが取得できる" do
      get 'edit', :id => admin_users(:admin18_retailer_id_is_another_shop).id
      response.should be_success
      assigns[:admin_user].should == admin_users(:admin18_retailer_id_is_another_shop)
    end
    it "編集データが取得できない" do
      lambda { get 'edit', :id => 1 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  
  end


end
