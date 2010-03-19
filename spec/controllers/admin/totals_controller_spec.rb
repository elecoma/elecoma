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

describe Admin::TotalsController do
  fixtures :occupations, :customers, :orders, :order_deliveries, :order_details, :products , :admin_users 
  fixtures :product_styles
  before(:each) do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete these examples and add some real ones
  it "should use Admin::TotalsController" do
    controller.should be_an_instance_of(Admin::TotalsController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    it "集計の種類を指定しない場合は期間別" do
      get 'index'
      params[:page].should == 'term'
    end
    it "集計の種類におかしな物を指定した場合は期間別" do
      get 'index', :page => 'quickbrownfoxjumpsoverthelazydog'
      params[:page].should == 'term'
    end
  end

  describe "期間別集計" do
    it "タイトル" do
      get 'index', :page => 'term'
      assigns[:title].should == '期間別集計'
    end

    it "出力する項目名" do
      get 'index', :page => 'term'
      assigns[:labels].should == %W(期間 購入件数 男性 女性 小計 値引 手数料 送料 購入合計 購入平均)
    end

    it "集計タイプ (日別、月別等) のリンク" do
      post 'index', :page => 'term', :search => { 'month(1i)'=>2008, 'month(2i)'=>6 }
      assigns[:links].should == ['日別', 'day', '月別', 'month', '年別', 'year', '曜日別', 'wday', '時間別', 'hour']
    end

    it "月、期間を指定しない場合は一覧を表示しない" do
      get 'index', :page => 'term'
      assigns[:records].should be_nil
    end

    it "指定された月の一覧を表示する" do
      search = {
        'month(1i)'=>2008, 'month(2i)'=>6,
        'date_from(1i)'=>2008, 'date_from(2i)'=>6, 'date_from(3i)'=>29,
        'date_to(1i)'=>2008, 'date_to(2i)'=>7, 'date_to(3i)'=>1,
        'by_month'=>'xxx'
      }
      post 'index', :page => 'term', :search => search
      assigns[:records].size.should == 30
    end

    it "指定された期間の一覧を表示する(両端とも含む)" do
      search = {
        'month(1i)'=>2008, 'month(2i)'=>6,
        'date_from(1i)'=>2008, 'date_from(2i)'=>6, 'date_from(3i)'=>29,
        'date_to(1i)'=>2008, 'date_to(2i)'=>7, 'date_to(3i)'=>1,
        'by_date'=>'xxx'
      }
      post 'index', :page => 'term', :search => search
      assigns[:records].size.should == 3
    end

    it "ボタンを押さずに送信した場合は月別" do
      search = {
        'month(1i)'=>2008, 'month(2i)'=>6,
        'date_from(1i)'=>2008, 'date_from(2i)'=>6, 'date_from(3i)'=>29,
        'date_to(1i)'=>2008, 'date_to(2i)'=>7, 'date_to(3i)'=>1
      }
      post 'index', :page => 'term', :search => search
      assigns[:records].size.should == 30
    end

    it "合計を表示する(検索結果0)" do
      post 'index', :page => 'term', :search => { 'month(1i)'=>1978, 'month(2i)'=>6, 'by_month'=>'x' }
      assigns[:total].should_not be_nil
      assigns[:total]['total'].should == 0
    end


    it "合計を表示する(検索結果複数)" do
      post 'index', :page => 'term', :type => 'wday', :search => {
        'date_from(1i)'=>2000, 'date_from(2i)'=>1, 'date_from(31)'=>1,
        'date_to(1i)'=>2030, 'date_to(2i)'=>9, 'date_to(3i)'=>9, 'by_date'=>'x'
      }
      assigns[:total]['total'].should > 0
    end

    it "日別表示" do
      search = {
        'date_from(1i)'=>2008, 'date_from(2i)'=>3, 'date_from(3i)'=>1,
        'date_to(1i)'=>2009, 'date_to(2i)'=>2, 'date_to(3i)'=>28,
        'by_date'=>'x'
      }
      post 'index', :page => 'term', :type => 'day', :search => search
      assigns[:records].size.should == 365
    end

    it "月別表示" do
      search = {
        'date_from(1i)'=>2008, 'date_from(2i)'=>6, 'date_from(3i)'=>29,
        'date_to(1i)'=>2008, 'date_to(2i)'=>7, 'date_to(3i)'=>1,
        'by_date'=>'x'
      }
      post 'index', :page => 'term', :type => 'month', :search => search
      assigns[:records].size.should == 2
    end

    it "年別表示" do
      search = {
        'date_from(1i)'=>2001, 'date_from(2i)'=>6, 'date_from(3i)'=>29,
        'date_to(1i)'=>2012, 'date_to(2i)'=>7, 'date_to(3i)'=>1,
        'by_date'=>'x'
      }
      post 'index', :page => 'term', :type => 'year', :search => search
      assigns[:records].size.should == 12
    end

    it "曜日別表示" do
      search = {
        'date_from(1i)'=>2001, 'date_from(2i)'=>1, 'date_from(3i)'=>1,
        'date_to(1i)'=>2001, 'date_to(2i)'=>1, 'date_to(3i)'=>1,
        'by_date'=>'x'
      }
      post 'index', :page => 'term', :type => 'wday', :search => search
      assigns[:records].size.should == 7
    end

    it "時間別表示" do
      search = {
        'date_from(1i)'=>2001, 'date_from(2i)'=>1, 'date_from(3i)'=>1,
        'date_to(1i)'=>2001, 'date_to(2i)'=>1, 'date_to(3i)'=>1,
        'by_date'=>'x'
      }
      post 'index', :page => 'term', :type => 'hour', :search => search
      assigns[:records].size.should == 24
    end

#    it "total 等を合計する" do
#      OrderDelivery.find(:all).each do | o |
#        o.save!
#      end
#      date_from = DateTime.new(2008, 8, 1, 0, 0, 0)
#      date_to = DateTime.new(2008, 8, 31, 23, 59, 59)
#
#      conds = ['orders.received_at between ? and ? and status in (?)', date_from, date_to,
#               [OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO]]
#      record = OrderDelivery.find_sum(conds)
#      count = OrderDelivery.find(:all, :select => 'count(*) as count', :conditions => conds, :include => 'order').size
#
#      search = {'by_date'=>'x'}.merge(date_to_select(date_from, 'date_from')).merge(date_to_select(date_to, 'date_to'))
#      post 'index', :page => 'term', :type => 'day', :search => search
#      #assigns[:total]['subtotal'].should == record.subtotal
#      assigns[:total]['total'].should == record.total
#      #assigns[:total]['payment_total'].should == record.payment_total
#      #assigns[:total]['charge'].should == record.charge
#      #assigns[:total]['deliv_fee'].should == record.deliv_fee
#      #assigns[:total]['discount'].should == record.discount
#      assigns[:total]['count'].should == count
#      assigns[:total]['average'].should == record.total / count
#    end

  end

  describe "商品別集計" do
    it "タイトル" do
      get 'index', :page => 'product'
      assigns[:title].should == '商品別集計'
    end

    it "出力する項目名" do
      get 'index', :page => 'product'
      assigns[:labels].should == %W(順位 商品番号 商品名 購入件数 点数 単価 金額(税込) 販売開始期間)
    end

    it "集計タイプ (日別、月別等) のリンク" do
      post 'index', :page => 'product', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:links].should == ['全体', 'all', '会員', 'member', '非会員', 'nomember']
    end

    it "初期集計タイプ" do
      get 'index', :page => 'product'
      params[:type] = 'all'
    end

    it "月、期間を指定しない場合は一覧を表示しない" do
      get 'index', :page => 'product'
      assigns[:records].should be_nil
    end

    it "指定された月の一覧を表示する" do
      post 'index', :page => 'product', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "金額の降順に並ぶ" do
      post 'index', :page => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      previous_price = nil
      assigns[:records].each do | r |
        if not previous_price.nil?
          r['price'].should <= previous_price
        end
        previous_price = r['price']
      end
    end

    it "全体" do
      post 'index', :page => 'product', :type => 'all', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "会員" do
      post 'index', :page => 'product', :type => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "非会員" do
      post 'index', :page => 'product', :type => 'nomember', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "販売開始期間の指定が可能" do
      get 'index', :page => 'product'
      assigns[:sale_start_enabled].should be_true
    end

    it "販売開始期間を指定して集計" do
      search = {
        'month(1i)'=>2008, 'month(2i)'=>8, :by_month => 'x',
        'sale_start_from(1i)' => '2008',
        'sale_start_from(2i)' => '08',
        'sale_start_from(3i)' => '01',
        'sale_start_to(1i)' => '2008',
        'sale_start_to(2i)' => '08',
        'sale_start_to(3i)' => '02'
      }
      start_from = Date.new(2008, 8, 1)
      start_to = Date.new(2008, 8, 2)
      post 'index', :page => 'product', :type => 'all', :search => search
      assigns[:sale_start_enabled].should be_true
      assigns[:records].should_not be_empty
      assigns[:records].each do | record |
        record.sale_start_at.should >= start_from
        record.sale_start_at.should <= start_to
      end
    end

    it "販売開始期間を指定しないと全て集計" do
      date_from = DateTime.new(2008,8,1,0,0,0)
      date_to = DateTime.new(2008,8,31,23,59,59)
      conds = ['received_at between ? and ? and status in (?)', date_from, date_to,
               [OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO]]
      search = {'by_date'=>'x'}.
        merge(date_to_select(date_from, 'date_from')).
        merge(date_to_select(date_to, 'date_to'))
      post 'index', :page => 'product', :type => 'all', :search => search
      response.should be_success
      assigns[:sale_start_enabled].should be_true
      assigns[:records].should_not be_empty
    end

  end

  describe "年代別集計" do
    it "タイトル" do
      get 'index', :page => 'age'
      assigns[:title].should == '年代別集計'
    end

    it "出力する項目名" do
      get 'index', :page => 'age'
      assigns[:labels].should == %W(年齢 購入件数 小計 値引 手数料 送料 購入合計 購入平均)
    end

    it "集計タイプ (日別、月別等) のリンク" do
      post 'index', :page => 'age', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:links].should == ['全体', 'all']
    end

    it "初期集計タイプ" do
      get 'index', :page => 'age'
      params[:type] = 'all'
    end

    it "月、期間を指定しない場合は一覧を表示しない" do
      get 'index', :page => 'age'
      assigns[:records].should be_nil
    end

    it "指定された月の一覧を表示する" do
      post 'index', :page => 'age', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "並び順" do
      post 'index', :page => 'age', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records][0]['age'].should == '未回答'
      assigns[:records][1]['age'].should == '0～9歳'
      assigns[:records][2]['age'].should == '10～19歳'
      assigns[:records][3]['age'].should == '20～29歳'
      assigns[:records][4]['age'].should == '30～39歳'
      assigns[:records][5]['age'].should == '40～49歳'
      assigns[:records][6]['age'].should == '50～59歳'
      assigns[:records][7]['age'].should == '60～69歳'
      assigns[:records][8]['age'].should == '70歳～'
    end

    it "全体" do
      post 'index', :page => 'age', :type => 'all', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "会員" do
      post 'index', :page => 'age', :type => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "非会員" do
      post 'index', :page => 'age', :type => 'nomember', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

  end

  describe "職業別集計" do
    it "タイトル" do
      get 'index', :page => 'job'
      assigns[:title].should == '職業別集計'
    end

    it "出力する項目名" do
      get 'index', :page => 'job'
      assigns[:labels].should == %W(順位 職業 購入件数 小計 値引 手数料 送料 購入合計 購入平均)
    end

    it "集計タイプ (日別、月別等) のリンク" do
      post 'index', :page => 'job', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:links].should == ['全体', 'all']
    end

    it "初期集計タイプ" do
      get 'index', :page => 'job'
      params[:type] = 'all'
    end

    it "月、期間を指定しない場合は一覧を表示しない" do
      get 'index', :page => 'job'
      assigns[:records].should be_nil
    end

    it "指定された月の一覧を表示する" do
      post 'index', :page => 'job', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "順位" do
      post 'index', :page => 'job', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      previous_position = nil
      assigns[:records].each do | r |
        if not previous_position.nil?
          r['position'].should > previous_position
        end
        previous_position = r['position']
      end
    end

    it "購入合計の降順に並ぶ" do
      post 'index', :page => 'job', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      previous_total = nil
      assigns[:records].each do | r |
        if not previous_total.nil?
          r['total'].should <= previous_total
        end
        previous_total = r['total']
      end
    end
  end

  describe "会員別集計" do
    it "タイトル" do
      get 'index', :page => 'member'
      #assigns[:title].should == '会員別集計'
    end

    it "出力する項目名" do
      get 'index', :page => 'member'
      #assigns[:labels].should == %W(区分 購入件数 小計 値引 手数料 送料 購入合計 購入平均)
    end

    it "集計タイプ (日別、月別等) のリンク無し" do
      post 'index', :page => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:links].should be_nil
    end

    it "月、期間を指定しない場合は一覧を表示しない" do
      get 'index', :page => 'member'
      assigns[:records].should be_nil
    end

    it "指定された月の一覧を表示する" do
      post 'index', :page => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      assigns[:records].should_not be_nil
    end

    it "購入合計の降順に並ぶ" do
      post 'index', :page => 'member', :search => { 'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      previous_total = nil
      assigns[:records].each do | r |
        if not previous_total.nil?
          r['total'].to_i.should <= previous_total
        end
        previous_total = r['total'].to_i
      end
    end
  end

  describe "csv" do
    it "should be successful" do
      post 'csv', :page => "term", :search=> {:'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      response.should be_success
    end
    it "CSV を出力する" do
      post 'csv', :page => "term", :search=> {:'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      response.headers['Content-Type'].should =~ %r(^application/octet-stream)
    end
    it "ヘッダ+レコード数の行を出力" do
      post 'csv', :page => "term", :search=> {:'month(1i)'=>2008, 'month(2i)'=>6, :by_month => 'x' }
      rows = response.body.chomp.split("\n")
      #rows.size.should == assigns[:records].size + 1
      rows.size.should == 30 + 1 # 1ヶ月なので
    end
  end

  it "order_deliveries の total 等を合計する" do
  end

  it "日時は order_deliveries.commit_date を使用する" do
  end

  it "ステータスが発送中 or 配達完了の者を受注集計とする" do
  end

end
