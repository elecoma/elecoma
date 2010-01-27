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
end
