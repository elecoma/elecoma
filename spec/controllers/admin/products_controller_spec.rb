# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProductsController do
  fixtures :products, :admin_users, :authorities, :functions, :authorities_functions, :admin_users, :categories, :resource_datas, :image_resources
  fixtures :styles, :product_styles, :style_categories,:suppliers, :retailers

  before do
    session[:admin_user] = admin_users(:admin10)
    #Admin::BaseController.new
    #controller = Admin::ProductsController.new
    #Object.send(:remove_const, 'Admin::ProductsController')
    #load File.join(File.dirname(__FILE__), '../../../app/controllers/admin', 'products_controller.rb')
    #controller = Admin::ProductsController.new
    @controller.class.skip_before_filter @controller.class.before_filters
    @controller.class.skip_after_filter @controller.class.after_filters
  end


  #Delete this example and add some real ones
  it "should use Admin::ProductController" do
    controller.should be_an_instance_of(Admin::ProductsController)
  end

  describe "GET 'index'" do
    it "should be redirect" do
      #Function.find(:all).should be_nil
      #AuthoritiesFunction.find(:all).should be_nil
    #load File.join(File.dirname(__FILE__), '../../../app/controllers/admin', 'products_controller.rb')
    #@controller = Admin::ProductsController.new
      get 'index'
      assigns[:search].should_not be_nil
      response.should be_success
    end
  end

  describe "get 'search'" do 
    before(:each) do
      get "search"
    end

    it "should be successful" do 
      response.should be_success
    end

    it "should be get search" do 
      assigns[:search].should_not be_nil
    end

  end

  describe "GET 'search'" do
    before(:each) do
      @valid_product = products(:valid_product)
    end

    it "product_id" do
      get "search", :search => {:product_id => @valid_product.id.to_s}
    end

    it "name" do
      get "search", :search => {:name => @valid_product.name}
    end

    it "style" do
      get "search", :search => {:style => "valid_category"}
    end

    it "code" do
      get "search", :search => {:code => "AC001"}
    end
    it "code" do
      get "search", :search => {:supplier => 2}
    end
    it "category" do
      get "search", :search => {:category => @valid_product.category_id}
    end

    it "created_at" do
      search = {}
      search.merge! date_to_select(@valid_product.created_at, 'created_at_from')
      search.merge! date_to_select(@valid_product.created_at, 'created_at_to')
      get "search", :search => search
    end

    it "updated_at" do
      search = {}
      search.merge! date_to_select(@valid_product.updated_at, 'updated_at_from')
      search.merge! date_to_select(@valid_product.updated_at, 'updated_at_to')
      get "search", :search => search
    end

    it "sale_start_at" do
      search = {}
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_start')
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_end')
      get "search", :search => search
    end

    it "retailer_id" do
      get "search", :search => {:retailer_id => @valid_product.retailer_id, :product_id => @valid_product.id.to_s}
    end

    after(:each) do
      assigns[:products][0].should == @valid_product
    end
  end

  describe "GET 'new'" do
    it "normal" do
      get 'new'
      assigns[:product].should_not be_nil
    end

    it "copy" do
      get 'new', :id => 1, :copy => true
      assigns[:product].name.should == "商品1"
    end
  end

  describe "新規作成のケース" do

    before(:each) do
      require 'fileutils'
      @small_pic = ActionController::UploadedTempfile.new ""
      FileUtils.cp File.dirname(__FILE__) + "/../../../public/images/item/lt.gif", @small_pic.path
      @small_pic.reopen(@small_pic.path)
      @medium_pic = ActionController::UploadedTempfile.new ""
      FileUtils.cp File.dirname(__FILE__) + "/../../../public/images/item/lt.gif", @medium_pic.path
      @medium_pic.reopen(@medium_pic.path)
      @large_pic = ActionController::UploadedTempfile.new ""
      FileUtils.cp File.dirname(__FILE__) + "/../../../public/images/item/lt.gif", @large_pic.path
      @large_pic.reopen(@large_pic.path)
    end

    it "confirm単体" do
      resource_max = ImageResource.maximum(:id)
      post 'confirm', :product => {:small_resource => @small_pic, :medium_resource => @medium_pic, :large_resource => @large_pic, :name => "test", :category_id => 1, :introduction => "test intro", :description => "test desc", :retailer_id => 1}
      assigns[:product].small_resource_id.should_not be_nil
      assigns[:product].small_resource_id.should > resource_max
      response.should render_template("admin/products/confirm.html.erb")
    end

    it "confirm and create" do
      last_product = Product.find(:last)
      resource_max = ImageResource.maximum(:id)
      post 'confirm', :product => {:small_resource => @small_pic, :medium_resource => @medium_pic, :large_resource => @large_pic, :name => "test", :category_id => 1, :introduction => "test intro", :description => "test desc", :retailer_id => 1}
      product = assigns[:product]
      post 'create', :product => {:small_resource_id => product.small_resource_id, :medium_resource_id => product.medium_resource_id, :large_resource_id => product.large_resource_id, :name => "test", :category_id => 1, :introduction => "test intro", :description => "test desc", :retailer_id => 1}
      ImageResource.maximum(:id).should_not == resource_max
      Product.find(:last).should_not == last_product
      response.should redirect_to(:action => "show", :id => assigns[:product].id)
    end
  end
 
  describe "更新のケース" do
    before(:each) do
      @test_product = products(:valid_product)
    end

    it "confirm単体" do
      post 'confirm', :id => @test_product.id, :product => {:name => @test_product.name, :category_id => @test_product.category_id, :introduction => @test_product.introduction, :description => @test_product.description}, :product_small_resource_old_id => @test_product.small_resource_id, :product_medium_resource_old_id => @test_product.medium_resource_id
      response.should render_template("admin/products/confirm.html.erb")
    end

    it "confirm and update" do
      post 'confirm', :id => @test_product.id, :product => {:name => @test_product.name, :category_id => @test_product.category_id, :introduction => @test_product.introduction, :description => @test_product.description}, :product_small_resource_old_id => @test_product.small_resource_id, :product_medium_resource_old_id => @test_product.medium_resource_id
      post 'update', :id => @test_product.id, :product => {:name => @test_product.name, :category_id => @test_product.category_id, :introduction => @test_product.introduction, :description => @test_product.description, :small_resource_id => @test_product.small_resource_id, :medium_resource_id => @test_product.medium_resource_id}
      response.should redirect_to(:action => "show", :id => @test_product.id)

    end
  end

  describe "GET 'actual_count_index'" do
    it "should be successful" do
      get 'actual_count_index'
      assigns[:search].should_not be_nil
    end
  end

  describe "POST 'csv_upload'" do
    it "should be successful" do
      last_product = Product.find(:last)
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/product_sample.csv", "text", "product_sample.csv")
      post 'csv_upload', :upload_file => csv
      Product.find(:last).should_not == last_product
    end

    it "other shop should not be successful" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      last_product = Product.find(:last)
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/product_sample.csv", "text", "product_sample.csv")
      post 'csv_upload', :upload_file => csv
      p flash[:product_csv_upload_e]
      Product.find(:last).should == last_product
    end

    it "違うショップでもデータが正しければ登録できる" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      last_product = Product.find(:last)
      csv = uploaded_file(File.dirname(__FILE__) + "/../../csv/product_sample_other_shop.csv", "text", "product_sample_other_shop.csv")
      post 'csv_upload', :upload_file => csv
      p flash[:product_csv_upload_e]
      Product.find(:last).should_not == last_product
    end


  end


  describe "GET 'search' from retailer_fail" do
    before(:each) do
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      @valid_product = products(:valid_product)
    end

    it "product_id" do
      get "search", :search => {:product_id => @valid_product.id.to_s}
    end

    it "name" do
      get "search", :search => {:name => @valid_product.name}
    end

    it "style" do
      get "search", :search => {:style => "valid_category"}
    end

    it "code" do
      get "search", :search => {:code => "AC001"}
    end
    it "code" do
      get "search", :search => {:supplier => 2}
    end
    it "category" do
      get "search", :search => {:category => @valid_product.category_id}
    end

    it "created_at" do
      search = {}
      search.merge! date_to_select(@valid_product.created_at, 'created_at_from')
      search.merge! date_to_select(@valid_product.created_at, 'created_at_to')
      get "search", :search => search
    end

    it "updated_at" do
      search = {}
      search.merge! date_to_select(@valid_product.updated_at, 'updated_at_from')
      search.merge! date_to_select(@valid_product.updated_at, 'updated_at_to')
      get "search", :search => search
    end

    it "sale_start_at" do
      search = {}
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_start')
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_end')
      get "search", :search => search
    end

    it "retailer_id" do
      get "search", :search => {:retailer_id => @valid_product.retailer_id}
    end

    after(:each) do
      assigns[:products].should == []
    end
  end


end

