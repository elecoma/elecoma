# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::NewInformationsController do
  fixtures :new_informations, :authorities, :functions, :admin_users

  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :master_shop_check
  end
  #Delete this example and add some real ones
  it "should use Admin::NewInformationsController" do
    controller.should be_an_instance_of(Admin::NewInformationsController)
  end

  describe "GET 'index'" do
    it "should be status is create" do
      get 'index'
      #assigns[:status].should == "create"
      response.should be_success
    end
    it "マスターショップ以外はアクセスできない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end
  end

  describe "GET 'show'" do
    it "should be status is update" do
      get 'show', :id => new_informations(:success_validates_2).id
      #assigns[:status].should ==  "update"
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "recordのvalidateが通ったらstatusはconfirmになる" do
      record = {"name"=>"test", "date(1i)"=>"2008", "date(2i)"=>"1", "body"=>"", "date(3i)"=>"1", "url"=>"", "new_window"=>"0"}
      get 'create', :new_information => record
      assigns[:new_information].name.should == NewInformation.new(record).name
      response.should redirect_to(:action => "index")
    end

    it "recordのvalidateが通らなかったらstatusはcreateになる" do
      record = {"date(1i)"=>"2008", "date(2i)"=>"1", "date(3i)"=>"1"}
      get 'create', :new_information => record
      assigns[:new_information].date.should == NewInformation.new(record).date
      assigns[:new_information].should_not be_valid
      #assigns[:status].should == "create"
      #response.should render_template("admin/new_information/index")
    end
  end

  describe "GET 'update'" do
    it "recordのvalidateが通ったらstatusはconfirmになる" do
      id = new_informations(:success_validates_2).id
      get 'edit', :id => id
      record = {"name"=>"test", "date(1i)"=>"2008", "date(2i)"=>"1", "body"=>"", "date(3i)"=>"1", "url"=>"", "new_window"=>"0", :id => id}
      post 'confirm', :new_information => record
      get 'update', :new_information => record
      assigns[:new_information].id.should == new_informations(:success_validates_2).id
      assigns[:new_information].date.should == DateTime.parse("2008-01-01")
      #assigns[:status].should == "confirm"
      response.should redirect_to(:action => :index)
    end

    it "recordのvalidateが通らなかったらstatusはupdateになる" do
      id = new_informations(:success_validates_2).id
      get 'edit', :id => id
      record = {"name"=>"", "date(1i)"=>"2008", "date(2i)"=>"1", "date(3i)"=>"1"}
      post 'confirm', :new_information => record
      get 'update', :new_information => record
      assigns[:new_information].id.should == id
      assigns[:new_information].date.should == DateTime.parse("2008-01-01")
      response.should_not be_redirect
    end
  end

#  describe "GET 'complete'" do
#    it "データを更新する場合" do
#      id = new_informations(:success_validates_2).id
#      record = {"name"=>"test", "body"=>"", "date"=>"Thu Jun 19 00:00:00 +0900 2008", "url"=>"", "new_window"=>"0"}
#      get 'complete', :record => record, :id => id
#      NewInformation.find(id).name.should == "test"
#      response.should redirect_to("http://test.host/admin/new_information?model=new_information")
#    end
#
#    it "データを作成する場合" do
#      old_max_position = NewInformation.maximum(:position)
#      record = {"name"=>"test", "body"=>"", "date"=>"Mon Jun 09 00:00:00 +0900 2008", "url"=>"", "new_window"=>"0"}
#      get 'complete', :record => record, :id => nil
#      NewInformation.maximum(:position).should == old_max_position + 1
#      NewInformation.find(:first, 
#                          :conditions=>["position=?", NewInformation.maximum(:position)]).name.should == "test"
#      response.should redirect_to("http://test.host/admin/new_information?model=new_information")
#    end
#
#    it "データを初めて作成する場合" do
#      NewInformation.delete_all
#      record = {"name"=>"test", "body"=>"", "date"=>"Mon Jun 09 00:00:00 +0900 2008", "url"=>"", "new_window"=>"0"}
#      get 'complete', :record => record, :id => nil
#      NewInformation.maximum(:position).should == 1
#      NewInformation.find(:first, 
#                          :conditions=>["position=?", NewInformation.maximum(:position)]).name.should == "test"
#      response.should redirect_to("http://test.host/admin/new_information?model=new_information")
#    end
#  end

  describe "GET 'destroy'" do
    it "削除に成功する場合" do
      NewInformation.find(:first).id == 1
      get 'destroy', :id => 1
      flash[:notice].should == "削除しました"
      NewInformation.find(:first).id == 2
      response.should redirect_to("action" => "index")
    end

    it "削除に失敗する場合" do
      lambda { get 'destroy', :id => 100 }.should raise_error(ActiveRecord::RecordNotFound)
      #flash[:error].should == "削除に失敗しました"
      #response.should redirect_to(:action => "index", :model => "new_information")
    end
  end

  describe "GET 'up'" do
    it "ポジションを移動させる場合(上に移動)" do
      old_position = new_informations(:success_validates_2).position
      #record_move = {"position"=>"3"}
      id = new_informations(:success_validates_2).id
      #get 'sort', :move => "move", :id => id, :record_move => record_move
      get 'up', :id => id
      NewInformation.find(id).position.should == 1
      #NewInformation.find(:all, :order=>"position").each_with_index do |record, index|
      #  p record.position
      #end

      response.should redirect_to("action" => "index")
    end
    it "ポジションを移動させる場合（下に移動）" do
      old_position = new_informations(:load_by_portal_test_position_one).position
      #record_move = {"position"=>"3"}
      id = new_informations(:load_by_portal_test_position_one).id
      #get 'sort', :move => "move", :id => id, :record_move => record_move
      get 'down', :id => id
      NewInformation.find(id).position.should == 4
      #NewInformation(:all, :order=>"position").each_with_index do |record, index|
      #  record.position.should == indexa + 1
      #end

      response.should redirect_to("action" => "index")
    end
  end

  describe "GET 'edit'" do 
    it "編集画面に遷移" do
      get 'edit', :id => 1
      response.should be_success
    end

    it "編集画面に遷移できない場合" do
      lambda { get 'edit', :id => 100 }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "new_informationに不正な値をいれてみるとエラーになる" do
      lambda { get 'edit', :id => 1, :new_information => {"id" => "0", "date" => "2009-11-13 15:42:00 +0900", "name" => 'test', "new_window" => 0, "body" => ''} }.should raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe "POST 'confirm'" do
    it "新規作成から確認をした場合" do
      post "confirm", :new_information => {"date(1i)" => "2009", "date(2i)" => "11", "date(3i)" => "12", "date(4i)" => "18", "date(5i)" => '24', "name" => 'test', "new_window" => 0, "body" => ''}
      response.should_not redirect_to("action" => "new")
    end

    it "編集から確認をした場合" do
      post "confirm", :new_information => {:id => 1, "date(1i)" => "2009", "date(2i)" => "11", "date(3i)" => "12", "name" => 'test', "body" => ''} 
      #p response
      response.should render_template("admin/new_informations/confirm.html.erb")
    end

    it "新規作成で登録できない場合" do
      post "confirm", :new_information => {"date(1i)" => "2009", "date(2i)" => "11", "date(3i)" => "12", "date(4i)" => "18", "date(5i)" => '24', "new_window" => 0, "body" => '', "url" => "ftp://ftp.example.com"}
      response.should render_template("admin/new_informations/new.html.erb")
    end

    it "編集から登録できない場合" do
      post "confirm", :new_information => {:id => 1, "date(1i)" => "2009", "date(2i)" => "11", "date(3i)" => "12"} 
      #p response
      response.should render_template("admin/new_informations/edit.html.erb")
    end

    it "新規作成の確認から戻るを押した場合" do
      get "new", :new_information => {"date" => "2009-11-13 15:42:00 +0900", "name" => 'test', "new_window" => 0, "body" => ''}
      assigns[:new_information].should_not be_nil
      assigns[:new_information].name.should == 'test'
      assigns[:new_information].date.month.should == 11
    end

    it "編集の確認から戻るを押した場合" do
      get "edit", :id => 1, :new_information => {"id" => "1", "date" => "2009-11-13 15:42:00 +0900", "name" => 'test', "new_window" => 0, "body" => ''}
      assigns[:new_information].should_not be_nil
      assigns[:new_information].name.should == 'test'
      assigns[:new_information].date.month.should == 11
    end      

  end


  describe "get 'change_position'" do
    it "1 から 3へ" do
      old_info = NewInformation.find_by_id(1)
      old_info.position.should == 1
      get "change_position", :id => 1, :position => 3
      new_info = NewInformation.find_by_id(1)
      new_info.position.should == 3
      response.should redirect_to("action" => "index")
    end
  end
  

end
