# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ReturnItemsController do
  fixtures :products, :product_order_units, :admin_users,:product_styles
  fixtures :return_items

  before do
    @controller.class.skip_before_filter @controller.class.before_filters
    @controller.class.skip_after_filter @controller.class.after_filters
    @pou = product_order_units(:have_classcategory2)
    @ri = return_items(:return_items_1)
    session[:admin_user] = admin_users(:admin10)
  end

  it "should use Admin::ProductController" do
    controller.should be_instance_of(Admin::ReturnItemsController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get "index"
      response.should be_success
    end
  end

  describe "GET 'search;" do

    it "should ok" do
      search = {:name => ""}
      get "search", :condition => search
      response.should be_success
      assigns[:pous].size.should > 0
    end

    it "with name" do
      search = {:name => @pou.ps.product.name}
      get "search", :condition => search
      response.should be_success
      assigns[:pous][0].ps.product.name.should == @pou.ps.product.name
    end

    it "with product_id" do
      search = {:product_id => @pou.ps.product.id}
      get "search", :condition => search
      response.should be_success
      assigns[:pous][0].ps.product.id.should == @pou.ps.product.id
    end

    it "with code" do
      search = {:code => @pou.product_style.code}
      get "search", :condition => search
      response.should be_success
      assigns[:pous][0].product_style.code.should == @pou.product_style.code
    end

    it "with manufacturer" do
      search = {:manufacturer => @pou.product_style.manufacturer_id}
      get "search", :condition => search
      response.should be_success
      assigns[:pous][0].product_style.manufacturer_id.should == @pou.product_style.manufacturer_id
    end

    it "with fail_retailer" do
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      search = {}
      get "search", :condition => search
      response.should be_success
      assigns[:pous].should == []
    end

  end

  describe "GET 'new'" do

    it "should ok" do
      get "new", :id => @pou.id
      response.should be_success
    end

    it "no id, should redirect to index" do
      get "new"
      response.should redirect_to(:action => :index)
    end

  end

  describe "POST 'create'" do
    it "should ok" do
      return_item = {:product_id => @pou.ps.product_id,
        :product_order_unit_id => @pou.id,
        :returned_count => 2,
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "1",
        "returned_at(3i)" => "1",
        :comment => "test"}
      post 'create', :return_item => return_item
      response.should redirect_to(:action => :index)
    end

    it "without product_id is error" do
      return_item = {:product_order_unit_id => @pou.id,
        :returned_count => 2,
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "1",
        "returned_at(3i)" => "1",
        :comment => "test"}
      post 'create', :return_item => return_item
      response.should render_template('admin/return_items/new.html.erb')
    end

    it "without returned_at is error" do
      return_item = {:product_id => @pou.ps.product.id,
        :product_order_unit_id => @pou.id,
        :returned_count => 2,
        "returned_at(1i)" => "",
        "returned_at(2i)" => "",
        "returned_at(3i)" => "",
        :comment => "test"}
      post 'create', :return_item => return_item
      response.should render_template('admin/return_items/new.html.erb')
    end

    it "returned_count < 0 is error" do
      return_item = {:product_id => @pou.ps.product_id,
        :product_order_unit_id => @pou.id,
        :returned_count => "-3",
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "1",
        "returned_at(3i)" => "1",
        :comment => "test"}
      post 'create', :return_item => return_item
      response.should render_template('admin/return_items/new.html.erb')
    end
  end

  describe "GET 'history'" do
    it "should ok" do
      get 'history'
      response.should be_success
    end
  end

  describe "GET 'history_search'" do

    it "should ok" do
      condition = {:name => ""}
      get 'history_search', :condition => condition
      assigns[:return_items].size.should > 0
      response.should be_success
    end

    it "with name" do
      condition = {:name => @ri.path_product.product.name}
      get 'history_search', :condition => condition
      assigns[:return_items][0].path_product.product.name.should == @ri.path_product.product.name
      response.should be_success
    end

    it "with code" do
      condition = {:code => @ri.product_order_unit.product_style.code}
      get 'history_search', :condition => condition
      assigns[:return_items][0].product_order_unit.product_style.code.should == @ri.product_order_unit.product_style.code
      response.should be_success
    end

    it "with product_id" do
      condition = {:product_id => @ri.path_product.product.id}
      get 'history_search', :condition => condition
      assigns[:return_items][0].path_product.product.id.should == @ri.path_product.product.id
      response.should be_success
    end

    it "with manufacturer" do
      condition = {:manufacturer => @ri.product_order_unit.product_style.manufacturer_id}
      get 'history_search', :condition => condition
      assigns[:return_items][0].product_order_unit.product_style.manufacturer_id.should == @ri.product_order_unit.product_style.manufacturer_id
      response.should be_success
    end

    it "is fail_retailer" do
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      condition = {:name => ""}
      get 'history_search', :condition => condition
      assigns[:return_items].size.should == 0
      response.should be_success
    end


  end

  describe "GET 'edit'" do
    it "should ok" do
      get 'edit', :id => @ri.id
      response.should be_success
    end

    it "without id is error" do
      get 'edit'
      response.should redirect_to(:action => :history)
    end
  end

  describe "POST 'update'" do
    it "should ok" do
      get 'edit', :id => @ri.id
      return_item = {:id => @ri.id,
        :product_id => @ri.path_product.product.id,
        :product_order_unit_id => @ri.product_order_unit_id,
        :returned_count => 3,
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "2",
        "returned_at(3i)" => "3",
        :comment => "Test"}
      post 'update', :return_item => return_item
      response.should redirect_to(:action => :history)
    end

    it "without comment is error" do
      get 'edit', :id => @ri.id
      return_item = {:id => @ri.id,
        :product_id => @ri.path_product.product.id,
        :product_order_unit_id => @ri.product_order_unit_id,
        :returned_count => 3,
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "2",
        "returned_at(3i)" => "3",
        :comment => ""}
      post 'update', :return_item => return_item
      response.should render_template("admin/return_items/edit.html.erb")
    end
  end

  describe "POST 'destroy'" do
    it "should ok" do
      post 'destroy', :id => @ri.id
      response.should redirect_to(:action => :history)
    end

    it "without id is error" do
      lambda{post 'destroy'}.should raise_error(NoMethodError)
    end
  end

  describe "GET 'csv_index'" do
    it "should ok" do
      get 'csv_index'
      response.should be_success
    end
  end

  describe "GET 'new_csv'" do
    it "should ok" do
      get 'new_csv'
      response.should be_redirect
    end
  end

  describe "GET 'csv'" do
    it "should ok" do 
      csv_line_count = ReturnItem.find(:all).size + 1
      get 'csv', :id => DateTime.now.strftime('%Y%m%d_%H%M%S')
      response.body.count("\n").should == csv_line_count
    end

    it "cache is ok" do
      pending "テストではキャッシュが有効にならないため"
      id = DateTime.now.strftime('%Y%m%d_%H%M%S')
      csv_line_count = ReturnItem.find(:all).size + 1
      get 'csv', :id => id
      response.body.count("\n").should == csv_line_count
      return_item = {:product_id => @pou.ps.product_id,
        :product_order_unit_id => @pou.id,
        :returned_count => 2,
        "returned_at(1i)" => "2010",
        "returned_at(2i)" => "1",
        "returned_at(3i)" => "1",
        :comment => "test"}
      post 'create', :return_item => return_item
      get 'csv', :id => id
      response.body.count("\n").should == csv_line_count
    end      

    it "is retailer_fail" do 
      session[:admin_user] = admin_users(:admin17_retailer_id_is_fails)
      get 'csv', :id => DateTime.now.strftime('%Y%m%d_%H%M%S')
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      rows = response.body.chomp.split("\n")
      rows.size.should == 1
    end
  end
end


