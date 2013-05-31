# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::MailMagazinesController do
  fixtures :authorities, :functions, :admin_users, :mail_magazine_templates, :customers, :mail_magazines, :mails
  fixtures :orders, :order_deliveries, :order_details
  fixtures :campaigns_customers

  before do
    session[:admin_user] = admin_users(:admin_user_00011)
    @condition = MailMagazineSearchForm.new({})
    @mail_magazine = mail_magazines(:one)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :master_shop_check
  end

  #Delete this example and add some real ones
  it "should use Admin::MailMagazineController" do
    controller.should be_an_instance_of(Admin::MailMagazinesController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      assigns[:condition].should_not be_nil
    end
    it "マスターショップ以外はアクセスできない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end
  end

  describe "POST 'search'" do
    it "通常の検索" do
      on_form = 'true'
      post 'search', :on_form => on_form, :condition => {:form_type => "0", :email => "docomo"}
      session[:condition_save].should_not be_nil
      assigns[:customers].should_not be_nil
      assigns[:customers].size.should > 0
      assigns[:customer_ids].should_not be_blank
    end
    it "on_formがない場合" do
      post 'search', :condition => {:form_type => "0", :email => "docomo"}
      session[:except_list].should be_nil
    end
  end

  describe "POST 'except_customer'" do
    it "空の状態から削除" do
      session[:except_list] = []
      post 'except_customer', :id => 1, :checked => "false"
      session[:except_list].should == []
    end

    it "空の状態から追加" do
      session[:except_list] = []
      post 'except_customer', :id => 1, :checked => "true"
      session[:except_list].should == ["1"]
    end

    it "削除" do
      session[:except_list] = []
      session[:except_list] << "1"
      session[:except_list] << "2"
      post 'except_customer', :id => 1, :checked => "false"
      session[:except_list].should == ["2"]
    end

    it "追加" do
      session[:except_list] = []
      session[:except_list] << "1"
      session[:except_list] << "2"
      post 'except_customer', :id => 3, :checked => "true"
      session[:except_list].sort.should == ["1", "2", "3"].sort
    end
  end
  
  describe "POST 'except_customers'" do
    it "空の状態から削除" do
      session[:except_list] = []
      post 'except_customers', :customer_ids => "1,2,3", :checked => "false"
      session[:except_list].should == []
    end

    it "空の状態から追加" do
      session[:except_list] = []
      post 'except_customers', :customer_ids => "1,2,3", :checked => "true"
      session[:except_list].sort.should == ["1", "2", "3"].sort
    end
    
    it "削除" do
      session[:except_list] = []
      session[:except_list] << "1"
      session[:except_list] << "2"
      post 'except_customers', :customer_ids => "1,3,5", :checked => "false"
      session[:except_list].should == ["2"]
    end

    it "追加" do
      session[:except_list] = []
      session[:except_list] << "1"
      session[:except_list] << "2"
      post 'except_customers', :customer_ids => "1,3,5", :checked => "true"
      session[:except_list].sort.should == ["1", "2", "3", "5"].sort
    end
  end

  describe "GET 'template_search'" do
    it "should be successful" do
      get 'template_search', :customer_ids => "1,3,5"
      assigns[:contents].should_not be_nil
      assigns[:customer_ids].should == "1,3,5"
    end
  end

  describe "POST 'template_re_search'" do
    it "template_id is null" do
      post 'template_re_search'
      assigns[:contents][:form_type].should be_nil
      assigns[:contents][:subject].should be_nil
      assigns[:contents][:body].should be_nil
    end

    it "template_id = 1" do
      post 'template_re_search', :template_id => 1
      assigns[:contents][:form_type].should == 1
      assigns[:contents][:subject].should == "valid_success"
      assigns[:contents][:body].should == "valid_success"
    end

  end

  describe "POST 'confirm'" do
    it "確認画面に移動" do
      contents = {:subject => "subject", 
        :body => "dasda",
        :form_type => 2}
      post 'confirm', :contents => contents, :customer_ids => "1,3,5"
      response.should render_template("admin/mail_magazines/confirm.html.erb")
    end

    it "編集画面に戻る" do
      contents = {:subject => "", 
        :body => "",
        :form_type => 2}
      post 'confirm', :contents => contents, :customer_ids => "1,3,5"
      response.should render_template("admin/mail_magazines/template_search.html.erb")
    end
  end

  describe "POST 'complete'" do
    it "メールが送れるパターン" do
      #controller.stub!(:deliver_mail).and_return(1)
      #pending("メールマガ送信エラー修正中で、保留...")
      on_form = 'true'
      post 'search', :on_form => on_form, :condition => {:form_type => "0"}
      contents = {:subject => "subject", 
        :body => "dasda",
        :form_type => 2}
      post 'complete', :contents => contents, :customer_ids => "18"
      response.should redirect_to(:action => :history)
    end

    it "メールが送れないパターン" do
      controller.stub!(:deliver_mail).and_raise 'error'
      on_form = 'true'
      post 'search', :on_form => on_form, :condition => {:form_type => "0"}
      contents = {:subject => "subject", 
        :body => "asda",
        :form_type => 2}
      post 'complete', :contents => contents, :customer_ids => "0"
      response.should redirect_to(:action => :index)
    end

  end

  describe "POST 'history'" do
    it "should be successful" do
      post 'history'
      assigns[:histories].should_not be_nil
    end
  end

  describe "POST 'preview'" do
    it "should be successful" do
      post 'preview', :id => @mail_magazine.id
      assigns[:subject].should == @mail_magazine.subject
    end
  end

  describe "POST 'condition_view'" do
    it "should be successful" do
      post 'condition_view', :id => @mail_magazine.id
      assigns[:condition].should_not == {}
    end

  end

  describe "get 'destroy'" do
    it "should be successful" do
      MailMagazine.find_by_id(1).should_not be_nil
      get 'destroy', :id => @mail_magazine.id
      MailMagazine.find_by_id(1).should be_nil
      response.should redirect_to(:action => "history")
    end
  end

end
