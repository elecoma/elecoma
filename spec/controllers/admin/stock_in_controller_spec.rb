require 'spec_helper'

describe Admin::StockInController do
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
      assigns[:stock_history].stock_type.should == StockHistory::STOCK_IN
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 1000 }.should raise_error(ActiveRecord::RecordNotFound)
      assigns[:product_style].should be_nil
      assigns[:stock_history].should be_nil
    end
  end
  describe "POST 'update'" do
    it "正常に更新できるパターン" do
      before = ProductStyle.find_by_id(@ps.id).actual_count.to_i
      max_id = StockHistory.maximum(:id)
      sh = StockHistory.new(:storaged_count=>10,:comment=>"テスト")
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      flash[:stock_update].should == "データを保存しました"
      #更新後
      #商品規格
      check = ProductStyle.find_by_id(@ps.id).actual_count.to_i
      check.should == before + 10
      #操作履歴
      StockHistory.maximum(:id).should > max_id
      response.should redirect_to(:action => :index)
    end
    #入力チェックエラー
    #必須項目が未入力
    it "StockHistoryが不正なパターン" do
      sh = StockHistory.new(:storaged_count=>10)
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      check = ProductStyle.find_by_id(@ps.id).actual_count.to_i
      check.should == @ps.actual_count
      response.should_not be_redirect
      response.should render_template("admin/stock_in/edit.html.erb")
    end
    #入力値エラー
    #例、現実在庫数＋入庫数　< 0
    it "StockHistoryが不正なパターン" do
      sh = StockHistory.new(:storaged_count=>-10000,:comment=>"テスト")
      post 'update', :id => @ps.id, :stock_history => sh.attributes
      check = ProductStyle.find_by_id(@ps.id).actual_count.to_i
      check.should == @ps.actual_count
      response.should_not be_redirect
      response.should render_template("admin/stock_in/edit.html.erb")
    end
  end  
end
