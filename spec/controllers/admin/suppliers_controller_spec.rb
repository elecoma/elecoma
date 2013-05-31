# -*- coding: utf-8 -*-
require 'spec_helper'

describe Admin::SuppliersController do
  fixtures :admin_users,:suppliers,:prefectures, :retailers
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @supplier = suppliers(:one)
  end

  describe "GET 'index'" do
    it "成功する" do
      get 'index'
      assigns[:suppliers].should_not be_nil
    end
  end
  
  describe "GET 'search'" do
   
    it "should be successful" do
      get 'search', :condition => {}
      response.should be_success
      assigns[:suppliers].size.should == 4
    end

    it "conditionがないと検索ができない" do 
      get 'search'
      response.should render_template("admin/suppliers/index.html.erb")      
    end
    
    it "仕入先ID" do
      get 'search', :condition => {:supplier_id => '2'}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 1
      assigns[:suppliers][0].attributes.should == @supplier.attributes     
    end
    
    it "仕入先名" do
      get 'search', :condition => {:name => 'てすと'}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 2
      assigns[:suppliers][0].attributes.should == @supplier.attributes
      assigns[:suppliers][1].attributes.should == suppliers(:two).attributes       
    end
    
    it "担当者名" do
      get 'search', :condition => {:contact_name => "test"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 1
      assigns[:suppliers][0].attributes.should == suppliers(:three).attributes
    end
    
    it "メールアドレス" do
      get 'search', :condition => {:email => "test@kbmj.com"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 0
    end

    it "電話番号" do
      get 'search', :condition => {:tel_no => "0311111111"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 2
      assigns[:suppliers][0].attributes.should == @supplier.attributes
      assigns[:suppliers][1].attributes.should == suppliers(:three).attributes      
    end
    it "電話番号" do
      get 'search', :condition => {:fax_no => "0399999999"}
      response.should be_success
      # 結果の中に含まれているか見る
      assigns[:suppliers].size.should == 1
      assigns[:suppliers][0].attributes.should == suppliers(:three).attributes      
    end    

    it "違う販売元検索" do 
      not_master_shop = suppliers(:not_master_shop_1)
      get 'search', :condition => {:name => not_master_shop.name}
      response.should be_success
      assigns[:suppliers].size.should == 0      
    end
    it "違う販売元検索、admin_userが正しいケース" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      not_master_shop = suppliers(:not_master_shop_1)
      get 'search', :condition => {:name => not_master_shop.name}
      response.should be_success
      assigns[:suppliers].size.should == 1
    end

    it "admin_userがメインショップじゃない場合" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'search', :condition => {}
      response.should be_success
      assigns[:suppliers].size.should == 2
    end

  end
  describe "GET 'new'" do
    it "成功" do
      get 'new'
      assigns[:supplier].should_not be_nil
      assigns[:supplier].id.should be_nil
    end
  end
  describe "POST 'confirm'" do
    it "confirm" do
      post 'confirm', :supplier =>@supplier.attributes.merge({:name=>"テスト(株)"})
      assigns[:supplier].name.should == "テスト(株)"
      assigns[:supplier].contact_name.should == @supplier.contact_name
      assigns[:supplier].tel01.should == @supplier.tel01
      assigns[:supplier].tel02.should == @supplier.tel02  
      assigns[:supplier].tel03.should == @supplier.tel03
      assigns[:supplier].fax01.should == @supplier.fax01
      assigns[:supplier].fax02.should == @supplier.fax02
      assigns[:supplier].fax03.should == @supplier.fax03
      assigns[:supplier].zipcode01.should == @supplier.zipcode01
      assigns[:supplier].zipcode02.should == @supplier.zipcode02
      assigns[:supplier].prefecture_id.should == @supplier.prefecture_id
      assigns[:supplier].address_city.should == @supplier.address_city
      assigns[:supplier].address_detail.should == @supplier.address_detail
      assigns[:supplier].email.should == @supplier.email
      assigns[:supplier].percentage.should == @supplier.percentage
      assigns[:supplier].free_comment.should == @supplier.free_comment

      response.should render_template("admin/suppliers/confirm.html.erb")
      #validateエラーがある場合
      post 'confirm', :supplier => {:name => ""}
      response.should render_template("admin/suppliers/new.html.erb")
    end     
  end
  describe "GET 'edit'" do
    it "成功するパターン" do
      get 'edit', :id => @supplier.id
      assigns[:supplier].should_not be_nil
      assigns[:supplier].attributes.should == @supplier.attributes
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 1000 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "POST 'create'" do   
    it "正常に追加できるパターン" do
      max_id = Supplier.maximum(:id)
      post 'create', :supplier => @supplier.attributes.merge({:name=>"テスト(株)"})
      assigns[:supplier].should_not be_nil
      assigns[:supplier].id.should > max_id
      flash[:notice].should == "データを保存しました"
      response.should redirect_to(:action => :index)
    end

    it "supplierが不正なパターン" do
      max_id = Supplier.maximum(:id)
      post 'create', :supplier => {:name => ""}
      assigns[:supplier].should_not be_nil
      assigns[:supplier].id.should be_nil
      response.should_not be_redirect
      response.should render_template("admin/suppliers/new.html.erb")
    end

    it "retailer_idが不正なパターン" do
      retailer_max = Retailer.find(:last).id + 100
      post 'create', :supplier => @supplier.attributes.merge({"name" => "retailer_fail", "retailer_id" => retailer_max})
      assigns[:supplier].should_not be_nil
      assigns[:supplier].id.should be_nil
      response.should_not be_redirect
      response.should render_template("admin/suppliers/new.html.erb")
    end

  end
  
  describe "POST 'update'" do
    it "正常に更新できるパターン" do
      post 'update', :id => @supplier.id, :supplier => @supplier.attributes.merge(:name=>"(株)テスト")
      flash[:notice].should == "データを保存しました"
      #更新後
      check = Supplier.find_by_id(@supplier.id)
      check.name.should == "(株)テスト"
      response.should redirect_to(:action => :index)
    end

    it "supplierが不正なパターン" do
      post 'update', :id => @supplier.id, :supplier => {:name => ""}
      check = Supplier.find_by_id(@supplier.id)
      check.attributes.should == @supplier.attributes
      response.should_not be_redirect
      response.should render_template("admin/suppliers/edit.html.erb")
    end
  end
  describe "POST 'destroy'" do
    it "成功に削除" do
      Supplier.find_by_id(3).should_not be_nil
      post 'destroy', :id => 3
      Supplier.find_by_id(3).should be_nil
    end
    it "ID=2のデータは商品を持っているので削除不可" do
      lambda { post 'destroy', :id => @supplier.id }.should raise_error(ActiveRecord::ReadOnlyRecord)
    end    
    it "ID=1のデータが削除不可" do
      lambda { post 'destroy', :id => 1 }.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end  
end
