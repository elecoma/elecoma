# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProductSetsController do
  fixtures :product_sets,:product_order_units,:products, :admin_users,:product_set_styles,:product_styles
  fixtures :retailers,:suppliers, :categories, :resource_datas, :image_resources

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter :admin_permission_check_product 
  end

  it "should use Admin::ProductController" do
    controller.should be_an_instance_of(Admin::ProductSetsController)
  end

  describe "GET 'index'" do
    it "should be redirect" do
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
      @valid_set = product_sets(:valid_set)
      @valid_set_product = products(:valid_set_product)
    end

    it "product_set_id" do
      get "search", :search => {:product_set_id => @valid_set.id.to_s}
    end

    it "set_product_name" do
      get "search", :search => {:name => @valid_set_product.name}
    end

    it "category" do
      get "search", :search => {:category => @valid_set_product.category_id}
    end

    it "created_at" do
      search = {}
      search.merge! date_to_select(@valid_set.created_at, 'created_at_from')
      search.merge! date_to_select(@valid_set.created_at, 'created_at_to')
      get "search", :search => search
    end

    it "updated_at" do
      search = {}
      search.merge! date_to_select(@valid_set.updated_at, 'updated_at_from')
      search.merge! date_to_select(@valid_set.updated_at, 'updated_at_to')
      get "search", :search => search
    end

    it "sale_start_at" do
      search = {}
      search.merge! date_to_select(@valid_set_product.sale_start_at, 'sale_start_at_start')
      search.merge! date_to_select(@valid_set_product.sale_start_at, 'sale_start_at_end')
      get "search", :search => search
    end

    after(:each) do
      assigns[:product_sets][0].should == @valid_set
    end
  end

  describe "GET 'search' でエラーになるケース" do
    before do
      @minus_value_start = ["-2000", "3", "24"]
      @minus_value_end = ["-1999", "3", "24"]
      @old_value_start = ["1800", "3", "24"]
      @old_value_end = ["1801", "3", "24"]
    end 

    it "sale_start_atにマイナスの日付" do
      search = {}
      search.merge! array_to_time(@minus_value_start, 'sale_start_at_start')
      search.merge! array_to_time(@minus_value_end, 'sale_start_at_end')
      get "search", :search => search
    end 
    it "sale_start_atに古すぎる日付" do
      search = {}
      search.merge! array_to_time(@old_value_start, 'sale_start_at_start')
      search.merge! array_to_time(@old_value_end, 'sale_start_at_end')
      get "search", :search => search
    end 
    
    after do
      response.should be_success
    end 

  end 

  describe "GET 'search_ps' でエラーになるケース" do
    before do
      @minus_value_start = ["-2000", "3", "24"]
      @minus_value_end = ["-1999", "3", "24"]
      @old_value_start = ["1800", "3", "24"]
      @old_value_end = ["1801", "3", "24"]
    end 

    it "sale_start_atにマイナスの日付" do
      search = {}
      search.merge! array_to_time(@minus_value_start, 'sale_start_at_start')
      search.merge! array_to_time(@minus_value_end, 'sale_start_at_end')
      get "search_ps", :search => search
    end 
    it "sale_start_atに古すぎる日付" do
      search = {}
      search.merge! array_to_time(@old_value_start, 'sale_start_at_start')
      search.merge! array_to_time(@old_value_end, 'sale_start_at_end')
      get "search_ps", :search => search
    end 
    
    after do
      response.should be_success
    end 

  end 


  describe "get 'search_ps'" do
    before(:each) do
      get "search_ps"
    end

    it "should be successful" do
      response.should be_success
    end

    it "should be get search" do
      assigns[:search].should_not be_nil
    end

  end

  describe "GET 'search_ps'" do
    before(:each) do
      @valid_ps = product_styles(:valid_product)
      @valid_product = products(:valid_product)
    end

    it "product_style_id" do
      get "search_ps", :search => {:style_id => @valid_ps.id.to_s}
    end

    it "style_name" do
      get "search_ps", :search => {:style_name => @valid_ps.name}
    end

    it "style_code" do
      get "search_ps", :search => {:code => @valid_ps.code}
    end

    it "product_name" do
      get "search_ps", :search => {:product_name => @valid_product.name}
    end

    it "category" do
      get "search_ps", :search => {:category => @valid_product.category_id}
    end

    it "created_at" do
      search = {}
      search.merge! date_to_select(@valid_ps.created_at, 'created_at_from')
      search.merge! date_to_select(@valid_ps.created_at, 'created_at_to')
      get "search_ps", :search => search
    end

    it "updated_at" do
      search = {}
      search.merge! date_to_select(@valid_ps.updated_at, 'updated_at_from')
      search.merge! date_to_select(@valid_ps.updated_at, 'updated_at_to')
      get "search_ps", :search => search
    end

    it "sale_start_at" do
      search = {}
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_start')
      search.merge! date_to_select(@valid_product.sale_start_at, 'sale_start_at_end')
      get "search_ps", :search => search
    end

    after(:each) do
      assigns[:product_styles][0].should == @valid_ps
    end
  end
  

  describe "セットへの商品追加" do
    it "何も入っていないセットに追加する" do
      @valid_ps = product_styles(:valid_product)
      get 'add_product',:id => @valid_ps.id
      assigns[:sets][0].product_style_id.should == @valid_ps.id
    end
    
    it "中身があるセットに追加する" do
      @valid_ps = product_styles(:can_incriment)
      @sets = product_sets(:valid_set)
      get 'add_product',:id => @valid_ps.id
      assigns[:sets][0].product_style_id.should == @valid_ps.id
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
    end

    it "confirm単体" do
      resource_max = ImageResource.maximum(:id)
      post 'confirm', :product => {:price => "10000",:small_resource => @small_pic, :medium_resource => @medium_pic, :large_resource => @large_pic, :name => "test", :category_id => 1, :introduction => "test intro", :description => "test desc", :retailer_id => 1}
      assigns[:product].small_resource_id.should_not be_nil
      assigns[:product].small_resource_id.should > resource_max
      response.should render_template("admin/product_sets/confirm.html.erb")
    end

    it "confirm and regist" do
      last_product = Product.find(:last)
      last_set = ProductSet.find(:last)
      last_order_unit = ProductOrderUnit.find(:last)
      resource_max = ImageResource.maximum(:id)
      controller.session[:sets] = [product_set_styles(:set_style_test1),product_set_styles(:set_style_test2)]

      post 'confirm', :product => {:price => "10000",:small_resource => @small_pic, :medium_resource => @medium_pic, :large_resource => @large_pic, :name => "test", :category_id => 1, :introduction => "test intro", :description => "test desc", :retailer_id => 1}

      post 'regist',:product => {:category_id => "2",:supplier_id => "2",:set_flag => "true",:price => "10000",:small_resource => @small_pic, :medium_resource => @medium_pic, :large_resource => @large_pic, :name => "test", :introduction => "test intro", :description => "test desc", :retailer_id => "1",:sale_start_at => "2014-10-28 00:00:00",:sale_end_at => "2016-10-28 00:00:00",public_start_at: "2014-10-28 00:00:00",:public_end_at => "2015-10-28 00:00:00",:permit => "true",:arrival_expected_date => "2014-10-28 00:00:00"}

      ImageResource.maximum(:id).should_not == resource_max
      Product.find(:last).should_not == last_product
      ProductSet.find(:last).should_not == last_set
      ProductOrderUnit.find(:last).should_not == last_order_unit
      response.should redirect_to(:action => "show", :id => assigns[:show_id])
    end
  end
  describe "GET inc / dec" do
    before(:each) do
      @sets = [product_set_styles(:set_style_test1),product_set_styles(:set_style_test2)]
    end
    it "加算に成功する" do
      quantity_before =  @sets[0].quantity
      controller.session[:sets] = @sets
      get 'inc', {:id => @sets[0].product_style_id}
      assigns[:sets][0].quantity.should == quantity_before + 1
    end 
    it "減算に成功する" do
      @sets[0].quantity = 3
      quantity_before =  @sets[0].quantity
      controller.session[:sets] = @sets
      get 'dec', {:id => @sets[0].product_style_id}
      assigns[:sets][0].quantity.should == quantity_before - 1
    end
    it "減算すると0になる場合、減算せず1のままにする" do
      quantity_before =  @sets[0].quantity
      controller.session[:sets] = @sets
      get 'dec', {:id => @sets[0].product_style_id}
      assigns[:sets][0].quantity.should == quantity_before
    end
    after(:each) do
      response.should render_template("admin/product_sets/edit_items")
    end
  end 

  describe "destroy" do
    it "削除に成功する" do
      @product_set = product_sets(:valid_set)
      @style_top = product_styles(:valid_product)
      get 'destroy',{:id => @product_set.id} 
      response.should be_redirect
      response.should redirect_to(:action => 'index')
      ProductSet.find_by_id(@product_set)
      ProductOrderUnit.find(:first, :conditions => { :product_set_id => @product_set.id}).should be_nil 
      Product.find_by_id(@product_set.product_id).should be_nil
      ProductStyle.find_by_id(@style_top.id).set_ids.should == "" 
    end
  end
  describe "アイテムリストの破壊的操作" do
    it "リストをリセットする" do
      controller.session[:sets] = [product_set_styles(:set_style_test1),product_set_styles(:set_style_test2)]
      get 'reset'
      assigns[:sets].should be_blank
    end
    it "リストからあるアイテムを削除する" do
      @sets = [product_set_styles(:set_style_test1),product_set_styles(:set_style_test2)]
      controller.session[:sets] = @sets
      get 'del',{:id => @sets[0].product_style_id}
      assigns[:sets].should == [product_set_styles(:set_style_test2)]
    end
  end
end
