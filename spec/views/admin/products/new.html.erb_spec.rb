# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/products/new" do 
  fixtures :admin_users, :suppliers, :systems
  before(:each) do 
    
    assigns[:product] = Product.new 
    assigns[:product_statuses] = []
    assigns[:sub_products] = []
  end
  
  describe "販売元IDの仕入先一覧を得る" do 
    before(:each) do
      assigns[:system_supplier_use_flag] = true
    end
    it "メイン管理者" do 
      @admin_user = session[:admin_user] = admin_users(:load_by_admin_user_test_id_1)
    end

    it "メイン以外管理者" do 
      @admin_user = session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
    end

    after do 
      render 'admin/products/new'
      response.should have_tag("select#product_supplier_id") do 
        Supplier.list_by_retailer(@admin_user.retailer_id).each do |s|
          with_tag("option[value=?]", s.id)
        end
      end
    end
  end

end
