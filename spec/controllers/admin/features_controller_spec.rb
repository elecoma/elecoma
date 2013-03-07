# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FeaturesController do
  fixtures :admin_users,:features,:resource_datas, :image_resources
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :master_shop_check
  end
  
  #Delete this example and add some real ones
  it "should use Admin::FeaturesController" do
    controller.should be_an_instance_of(Admin::FeaturesController)
  end
  
  describe "GET 'index'" do
    it "成功する" do
      get 'index'
      assigns[:features].should_not be_nil
    end
    it "マスターショップ以外はアクセスできない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end
  end

  describe "GET 'new'" do
    it "成功" do
      get 'new'
      assigns[:feature].should_not be_nil
      assigns[:feature].id.should be_nil
    end
  end
  describe "POST 'confirm'" do
    before(:each) do
      require 'fileutils'
      @pic = ActionController::UploadedTempfile.new ""
      FileUtils.cp File.dirname(__FILE__) + "/../../../public/images/item/lt.gif", @pic.path
      @pic.reopen(@pic.path)
    end

    it "confirm単体(画像アップロードも含める)" do
      resource_max = ImageResource.maximum(:id)
      post 'confirm', :feature => {:name => "商品特集テストコード",:dir_name=>"test",:feature_type=>2,:image_resource=>@pic}
      assigns[:feature].name.should == "商品特集テストコード"
      assigns[:feature].dir_name.should == "test"
      assigns[:feature].feature_type.should == 2      
      assigns[:feature].image_resource_id.should_not be_nil
      assigns[:feature].image_resource_id.should > resource_max
      response.should render_template("admin/features/confirm.html.erb")
      #validateエラーがある場合
      post 'confirm', :feature => {:name => ""}
      response.should render_template("admin/features/new.html.erb")
    end     
  end
  describe "GET 'edit'" do
    it "成功するパターン" do
      get 'edit', :id => features(:free).id
      assigns[:feature].should_not be_nil
      assigns[:feature].attributes.should == features(:free).attributes
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 10000 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "POST 'create'" do   
    it "正常に追加できるパターン" do
      new_id = Feature.maximum(:id) + 1
      post 'create', :feature => {:name => "特集テストコード",:dir_name=>"test",:feature_type=>1}
      assigns[:feature].should_not be_nil
      assigns[:feature].id.should == new_id
      flash[:notice].should == "データを保存しました"
      check = Feature.find_by_id(new_id)
      check.name.should == "特集テストコード";
      check.dir_name.should == "test"
      check.feature_type.should == 1
      response.should redirect_to(:action => :index)
    end

    it "featureが不正なパターン" do
      new_id = Feature.maximum(:id) + 1
      post 'create', :feature => {:name => ""}
      assigns[:feature].should_not be_nil
      assigns[:feature].id.should be_nil
      response.should_not be_redirect
      response.should render_template("admin/features/new.html.erb")
    end
  end
  
  describe "POST 'update'" do
    before do
      @f_free = features(:free)
      @f_product = features(:permit)
    end    
    it "正常に更新できるパターン" do
      #更新前
      Feature.find_by_id(@f_product.id).name.should == @f_product.name
      post 'update', :id => @f_product.id, :feature => @f_product.attributes.merge(:name=>"商品特集編集テスト")
      flash[:notice].should == "データを保存しました"
      #更新後
      check = Feature.find_by_id(@f_product.id)
      check.name.should == "商品特集編集テスト"
      response.should redirect_to(:action => :index)
    end

    it "featureが不正なパターン" do
      post 'update', :id => @f_free.id, :feature => {:name => ""}
      check = Feature.find_by_id(@f_free.id)
      check.attributes.should == @f_free.attributes
      response.should_not be_redirect
      response.should render_template("admin/features/edit.html.erb")
    end      
  end  
end
