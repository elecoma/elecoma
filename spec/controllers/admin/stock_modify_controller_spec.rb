# -*- coding: utf-8 -*-
require 'spec_helper'

describe Admin::StockModifyController do

  fixtures :admin_users,:products,:product_styles,:suppliers,:stock_histories
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @ps = product_styles(:valid_product)
  end
  
  describe "GET 'index'" do
    it "成功する" do
      get 'index'
      response.should be_success
    end
  end
  describe "GET 'edit'" do
    it "成功するパターン" do
      get 'edit', :id => @ps.id
      assigns[:product_style].should_not be_nil
      assigns[:stock_history].should_not be_nil
      assigns[:stock_history].stock_type.should == StockHistory::STOCK_MODIFY
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 1000 }.should raise_error(ActiveRecord::RecordNotFound)
      assigns[:product_style].should be_nil
      assigns[:stock_history].should be_nil
    end
  end
  describe "POST 'update'" do
    it "正常に更新できるパターン" do
      before = ProductStyle.find_by_id(@ps.id)      
      max_id = StockHistory.maximum(:id)
      sh = StockHistory.new(:actual_adjustment=>10,:orderable_adjustment=>5,:broken_adjustment=>1,:comment=>"テスト")
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      flash[:stock_update].should == "データを保存しました"
      #更新後
      #商品規格
      check = ProductStyle.find_by_id(@ps.id)
      check.actual_count.should == before.actual_count.to_i + 10
      check.orderable_count.should == before.orderable_count.to_i + 5
      check.broken_count.should == before.broken_count.to_i + 1
      #操作履歴
      StockHistory.maximum(:id).should > max_id
      response.should redirect_to(:action => :index)
    end
    #入力チェックエラー
    #必須項目が未入力
    it "StockHistoryが不正なパターン" do
      sh = StockHistory.new
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      check = ProductStyle.find_by_id(@ps.id)
      check.attributes.should == @ps.attributes
      response.should_not be_redirect
      response.should render_template("admin/stock_modify/edit.html.erb")
    end
    #入力値エラー
    #販売可能数＋販可能調整数　< 0 あるいは  実在庫数＋実在庫調整数 < 0　あるいは　不良在庫数  + 不良在庫調整数 < 0
    it "StockHistoryが不正なパターン" do
      sh = StockHistory.new(:actual_adjustment=>-1000,:orderable_adjustment=>-10,:broken_adjustment=>-1,:comment=>"テスト")
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      check = ProductStyle.find_by_id(@ps.id)
      check.attributes.should == @ps.attributes
      response.should_not be_redirect
      response.should render_template("admin/stock_modify/edit.html.erb")
    end
  end 

  describe "POST 'edit_now'" do
    it "単一商品在庫保存：成功パターン" do
      before = ProductStyle.find_by_id(@ps.id)
      max_id = StockHistory.maximum(:id)
      xhr :post, :edit_now, :id => @ps.id, :product_style => {:actual_count => "100"}
      #更新後
      #商品規格  
      check = ProductStyle.find_by_id(@ps.id)
      check.actual_count.should == 100
      check.orderable_count.should == 100 - check.broken_count.to_i
      #操作履歴
      nmax_id = StockHistory.maximum(:id)
      nmax_id.should > max_id
      hs = StockHistory.find_by_id(nmax_id)
      hs.actual_count.should == 100
      hs.actual_adjustment.should == 100 - @ps.actual_count
      hs.orderable_count.should == 100 - @ps.broken_count unless @ps.broken_count.blank?
      hs.orderable_adjustment.should == 100 - @ps.broken_count - :@ps.actual_count unless @ps.broken_count.blank?
      response.should_not be_redirect
    end

    #入力在庫数 == @ps.actual_count
    it "単一商品在庫保存：変更なしパターン" do
      before = ProductStyle.find_by_id(@ps.id)
      max_id = StockHistory.maximum(:id)
      xhr :post, :edit_now, :id => @ps.id, :product_style => {:actual_count => "1000"}
      #更新後
      check = ProductStyle.find_by_id(@ps.id)
      check.attributes.should == @ps.attributes
      StockHistory.maximum(:id).should == max_id
      response.should_not be_redirect
    end

    #小数を含む入力
    it "単一商品在庫保存：入力不正パターン" do
      before = ProductStyle.find_by_id(@ps.id)
      max_id = StockHistory.maximum(:id)
      xhr :post, :edit_now, :id => @ps.id, :product_style => {:actual_count => "33.3"}
      #更新後
      check = ProductStyle.find_by_id(@ps.id)
      check.attributes.should == @ps.attributes
      StockHistory.maximum(:id).should == max_id
      response.should_not be_redirect
    end

    #入力在庫数 < 不良在庫数
    it "単一商品在庫保存：在庫不正パターン" do
      zaiko = product_styles(:zaiko);
      max_id = StockHistory.maximum(:id)
      before = ProductStyle.find_by_id(zaiko.id)
      xhr :post, :edit_now, :id => zaiko.id, :product_style => {:actual_count => "30"}
      #更新後
      check = ProductStyle.find_by_id(zaiko.id)
      check.attributes.should == zaiko.attributes
      StockHistory.maximum(:id).should == max_id
      response.should_not be_redirect
    end

    #在庫最大値オーバー
    it "単一商品在庫保存：入力過剰パターン" do
      before = ProductStyle.find_by_id(@ps.id)
      max_id = StockHistory.maximum(:id)
      lambda { xhr :post, :edit_now, :id => @ps.id, :product_style => {:actual_count => "2147483648"} }.should raise_error(ActiveRecord::StatementInvalid)
      #更新後
      check = ProductStyle.find_by_id(@ps.id)
      check.attributes.should == @ps.attributes
      StockHistory.maximum(:id).should == max_id
      response.should_not be_redirect
    end

  end
end
