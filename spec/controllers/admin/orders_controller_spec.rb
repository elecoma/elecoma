# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

# Date を date_select の形にする
def date_to_select date, name
  {
    name+'(1i)' => date.strftime('%Y'),
    name+'(2i)' => date.strftime('%m'),
    name+'(3i)' => date.strftime('%d')
  }
end

describe Admin::OrdersController, "/admin/order" do
  #set_fixture_class :'test/orders2' => Order
  self.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  fixtures :orders, :order_deliveries, :order_details
  #fixtures :csv_output_settings, :target_tables, :target_columns
  fixtures :styles, :systems
  fixtures :admin_users , :payments
  fixtures :functions, :authorities, :authorities_functions
  fixtures :products

  before do
    @order = orders(:one)
    @order_delivery = order_deliveries :nobi
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete this example and add some real ones
  it "should use Admin::OrdersController" do
    controller.should be_an_instance_of(Admin::OrdersController)
  end

  describe "GET / 検索条件入力" do
    before do
      get 'index', {:model => "orders"}
    end

    it "admin/order/list を表示する" do
      #response.should render_template("admin/order/list")
      response.should render_template("admin/orders/index.html.erb")
    end

    it "検索結果無し" do
      response.should be_success
      assigns[:order_delivery].should be_nil
    end
  end

  describe "POST / 検索結果表示" do
    fixtures :payments
#    it "条件に該当する受注一覧を表示" do
#      post 'search', :search => { :id => @order_delivery.id }
#      p assigns[:search].id
#      assigns[:order_deliveries][0].should == @order_delivery
#    end

    it "顧客名" do
      post 'search', :search => { :customer_name => @order_delivery.family_name }
      assigns[:order_deliveries][0].should == @order_delivery
    end

    it "顧客名" do
      post 'search', :search => { :customer_name => @order_delivery.first_name }
      assigns[:order_deliveries][0].should == @order_delivery
    end

    it "顧客名(カナ)" do
      post 'search', :search => { :customer_name_kana => @order_delivery.family_name_kana }
      assigns[:order_deliveries][0].should == @order_delivery
    end

    it "顧客名(カナ)" do
      post 'search', :search => { :customer_name_kana => @order_delivery.first_name_kana }
      assigns[:order_deliveries][0].should == @order_delivery
    end

    it "メールアドレス" do
      post 'search', :search => { :email => @order_delivery.email }
      assigns[:order_deliveries][0].should == @order_delivery
    end

    it "生年月日" do
      search = {}
      search.merge! date_to_select(@order_delivery.birthday, 'search_birth_from')
      search.merge! date_to_select(@order_delivery.birthday, 'search_birth_to')
      post 'search', :search => search
      assigns[:order_deliveries].each do | record |
        record.birthday.should == @order_delivery.birthday
      end
    end

    it "性別" do
      post 'search', :sex => ['0']
      assigns[:order_deliveries].each do | record |
        record.sex.should == '0'
      end
    end

    it "支払方法" do
      post 'search', :payment_id => ['1']
      assigns[:order_deliveries].each do | record |
        record.payment_id.to_i.should == 1
      end
    end

    it "登録・更新日" do
      search = {}
      search.merge! date_to_select(@order_delivery.updated_at, 'search_updated_at_from')
      search.merge! date_to_select(@order_delivery.updated_at, 'search_updated_at_to')
      post 'search', :search => search
      assigns[:order_deliveries].each do | record |
        record.updated_at.year.should == @order_delivery.updated_at.year
        record.updated_at.month.should == @order_delivery.updated_at.month
        record.updated_at.day.should == @order_delivery.updated_at.day
      end
    end

    it "購入金額" do
      search = { :total_from => @order_delivery.total, :total_to => @order_delivery.total }
      post 'search', :search => search
      assigns[:order_deliveries].each do | record |
        record.total == @order_delivery.total
      end
    end

#    it "配送日" do
#      search = {}
#      search.merge! date_to_select(@order_delivery.deliv_date, 'search_deliv_date_from')
#      search.merge! date_to_select(@order_delivery.deliv_date, 'search_deliv_date_to')
#      post 'search', :search => search
#      assigns[:order_deliveries].each do | record |
#        record.deliv_date.year.should == @order_delivery.deliv_date.year
#        record.deliv_date.month.should == @order_delivery.deliv_date.month
#        record.deliv_date.day.should == @order_delivery.deliv_date.day
#      end
#    end

    it "admin/order/list を表示する" do
      post 'search'
      response.should render_template("admin/orders/search.html.erb")
    end

    it "商品コードで検索" do
      code = 'NATSU0001'
      details = OrderDetail.find(:all, :conditions => ['product_code=?', code])
      expected = details.map(&:order_delivery).uniq.sort_by(&:id).reverse
      post 'search', :search => {:product_code => code, :per_page => expected.size}
      assigns[:order_deliveries].should == expected
    end

    it "電話番号(検索バグチェック用)" do
      post 'search', :search => { :tel => "is_not_invalid_value" }
      assigns[:order_deliveries].should == []
    end

  end

  describe "編集" do
    it "指定された Order を持ってくる" do
      get 'edit', :id => @order.id
      assigns[:order_delivery].should == @order.order_deliveries.first
    end
  end

  describe "更新" do
    before do
      System.stub!(:find).and_return(System.new)
    end

    it "入力された内容で更新する" do
      @order_delivery = order_deliveries(:customer_buy_one)
      post 'update', :id => @order_delivery.order_id, :order_delivery => {:first_name => '何某'}
      assigns[:order_delivery].first_name.should == '何某'
    end

#    it "確認ページを表示する" do
#      post 'update', :id => @order_delivery.id, :record => { :payment_id => 1}
#      response.should render_template("admin/order/confirm")
#    end

    it "エラーがある場合は再表示" do
      post 'update', :id => @order_delivery.id, :order_delivery => {:deliv_tel01 =>'でんわ'}
      response.should render_template("admin/orders/edit.html.erb")
    end

    it "商品一覧の更新" do
      details_input = {
        '1' => {:price => 100, :quantity => 200},
        '2' => {:price => 200, :quantity => 1}
      }
      post 'update', :id => @order_delivery.id,:order_delivery => { :payment_id => 1},  :detail => details_input
      response.should redirect_to(:action => 'index')
      assigns[:order_delivery].order_details.each do | detail |
        details_input[detail.id] or next
        detail.price.should == details_input[detail.id][:price]
        detail.quantity.should == details_input[detail.id][:quantity]
      end
    end

#    it "合計を計算する" do
#      # なんか変だ
#      @order_delivery.subtotal = -1
#      @order_delivery.total = -1
#      @order_delivery.payment_total = -1
#      post 'update', :id => @order_delivery.id, :record => {}
#      assigns[:order].subtotal.should > -1
#      assigns[:order].total.should > -1
#      assigns[:order].payment_total.should > -1
#    end
  end

  describe "「計算結果の確認」ボタン" do
    # update と同じ動きで edit を表示
    before do
      System.stub!(:find).and_return(System.new)
    end

    it "編集ページを表示する" do
      post 'recalculate', :id => @order_delivery.id, :order_delivery => {}
      response.should render_template("admin/orders/edit.html.erb")
    end

    it "エラーの場合も編集ページを表示する" do
      post 'recalculate', :id => @order_delivery.id, :order_delivery => {:deliv_fee => '無料'}
      response.should render_template("admin/orders/edit.html.erb")
    end

    it "合計を計算する" do
      @order_delivery.subtotal = -1
      @order_delivery.total = -1
      @order_delivery.payment_total = -1
      post 'update', :id => @order_delivery.order_id, :order_delivery => {}
      assigns[:order_delivery].subtotal.should > -1
      assigns[:order_delivery].total.should > -1
      assigns[:order_delivery].payment_total.should > -1
    end
  end


  describe "削除" do
    it "成功" do
      order = @order_delivery.order
      order_details = @order_delivery.order_details
      get :destroy, :id => @order_delivery.id
      Order.find(:first, :conditions=>["id=?",order.id]).should be_nil
      OrderDelivery.find(:first, :conditions=>["id=?",@order_delivery.id]).should be_nil
      order_details.each do | detail |
        OrderDetail.find(:first, :conditions=>["id=?",order.id]).should be_nil
      end
      flash[:error].should be_blank
    end
  end

  describe "CSV 出力" do
    it "成功する" do
      post 'csv_download'
      response.should be_success
    end
    it "CSV を出力する" do
      post 'csv_download'
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
    end
    it "ヘッダ+レコード数の行を出力" do
      post 'csv_download'
      rows = response.body.chomp.split("\n")
      get 'search'
      rows.size.should == OrderDelivery.find(:all).size + 1
      #p "rows: #{rows.size}"
      #p "OrderDelivery.find(:all).size: #{OrderDelivery.find(:all).size}"
    end
  end

  describe "POST 'destory'" do
    it "親子とも消す" do
      post 'destroy', :id => @order_delivery.id
      Order.find_by_id(@order_delivery.order_id).should be_nil
      OrderDelivery.find_by_id(@order_delivery.id).should be_nil
    end

    it "削除対象がない場合" do
      id = OrderDelivery.find(:last).id + 1
      post 'destroy', :id => id
    end
  end

end
