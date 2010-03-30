require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ShopsController do
  fixtures :authorities, :functions, :admin_users , :shops, :retailers
  
  before(:each) do
    session[:admin_user] = AdminUser.first
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end
  
  #Delete this example and add some real ones
  it "should use Admin::ShopsController" do
    controller.should be_an_instance_of(Admin::ShopsController)
  end
  
  
  
  describe "GET 'index'" do
    fixtures :shops,:systems
    it "should be successful" do
      get 'index'
      response.should be_success
      assigns[:shop].should == Shop.find(:first)
    end
  end
  
  describe "POST 'update'" do
    fixtures :shops,:systems
    it "should be successful" do
      shop = shops :load_by_shop_test_id_1
      system = systems :load_by_system_test_id_1
      #system = {:tax=>100,:tax_rule=>1,:free_delivery_rule=>5000}
      id = shops(:load_by_shop_test_id_1).id
      post 'update', :id => id, :shop => shop.attributes,:system=>system.attributes
      response.should redirect_to(:action => 'index')
      result = Shop.find(id)
       result.should == shop
#      result.name.should == shop.name
#      result.prefecture_id.should == shop.prefecture_id
#      result.address_city.should == shop.address_city
#      result.address_detail.should == shop.address_detail
#      result.tel.should == shop.tel
      system_new = System.find(:first)
      system_new.should == system
    end
  end
  
  
  describe "GET 'get_address'" do
    fixtures :zips,:shops,:systems
    it "get_address ok" do
      get 'get_address', :first => "000", :second => "0000"
      address = zips(:zip_test_id_1)
      data = address.prefecture_name + "/" + address.address_city + "/" + address.address_details + "/" + address.prefecture_id.to_s
      response.should be_success
      response.body.should == data
    end
  end
  
  #delivery関係
  describe "GET 'delivery_list'" do
    fixtures :delivery_traders,:delivery_times,:delivery_fees
    it "should be successful" do
      get 'delivery_index'
      response.should be_success
      assigns[:delivery_traders].should == DeliveryTrader.find(:all)
    end
  end
  
  describe "GET 'sort'" do
    fixtures :delivery_traders,:delivery_times,:delivery_fees
    
    it "positionを上げる場合" do
      DeliveryTrader.find(2).position.should == 2
      get 'up', :model => "delivery_traders", :id => 2, :return_act=>"delivery_list"
      DeliveryTrader.find(2).position.should == 1
      response.should redirect_to(:action => "delivery_list")
    end
    
    it "positionを上げる場合(これ以上あがらない)" do
      DeliveryTrader.find(1).position.should == 1
      get 'up', :model => "delivery_traders", :id => 1, :return_act=>"delivery_list"
      DeliveryTrader.find(1).position.should == 1
      response.should redirect_to(:action => "delivery_list")
    end
    
    
    it "positionを下げる場合" do
      DeliveryTrader.find(1).position.should == 1
      get 'down', :model => "delivery_traders", :id => 1, :return_act=>"delivery_list"
      DeliveryTrader.find(1).position.should == 2
      response.should redirect_to(:action => "delivery_list")
    end
    
    it "positionを下げる場合（これ以上下がらない）" do
      DeliveryTrader.find(2).position.should == 2
      get 'down', :model => "delivery_traders", :id => 2, :return_act=>"delivery_list"
      DeliveryTrader.find(2).position.should == 2
      response.should redirect_to(:action => "delivery_list")
    end
    
  end
  
  describe "GET 'destroy'" do
    it "削除に成功する" do
      get 'destroy', :model => "delivery_traders", :id => 1,:return_act=>"delivery_list"
      DeliveryTrader.find(:first).id.should == 2
      response.should redirect_to(:action => "delivery_list")
    end
    it "削除に失敗する場合" do
      get 'destroy', :model => "delivery_traders", :id => 100 ,:return_act=>"delivery_list"
    end
  end
  
  describe "GET 'delivery_new'" do
    it "should be successful" do
      get 'delivery_new'
      response.should be_success
    end
    
    it "新しい配送業者" do
      get 'delivery_new'
      response.should be_success
      
      assigns[:delivery_trader].should_not be_nil
      assigns[:delivery_time].should_not be_nil
      assigns[:delivery_fee].should_not be_nil
    end
  end
  
  describe "GET 'delivery_edit'" do
    fixtures :delivery_traders,:delivery_times,:delivery_fees
    before do
      @delivery_trader = delivery_traders :witch
      @delivery_time = @delivery_trader.delivery_times
      @delivery_fee = @delivery_trader.delivery_fees
    end
    it "編集" do
      get 'delivery_edit', :id=>@delivery_trader.id
      response.should be_success
      assigns[:delivery_trader].should == @delivery_trader
      DeliveryTime::MAX_SIZE.times do |index|
        assigns[:delivery_time][index].should == @delivery_time[index]
      end
      DeliveryFee::MAX_SIZE.times do |index|
        assigns[:delivery_fee][index].should == @delivery_fee[index]
      end
    end
  end
  
  describe "GET 'delivery_create'" do
    before do
      @delivery_trader = {:name=>"追加",:url=>"http://www.hoge.com", :retailer_id => Retailer::DEFAULT_ID}
      @delivery_time = {}
      DeliveryTime::MAX_SIZE.times do |i|
        @delivery_time["#{i}"]={:name=>"午前中なら#{i}"}
      end
      @delivery_fee = {}
      DeliveryFee::MAX_SIZE.times do |i|
        @delivery_fee["#{i}"]={:price=>"#{i}"}
      end
      @delivery_fee["47"][:prefecture_id]=nil
    end
    it "新規作成" do
      get 'delivery_create', :delivery_trader=>@delivery_trader,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee
      response.should redirect_to(:action=>:delivery_index)
    end
    
    it "新規作成（保存して戻る失敗）" do
      @delivery_trader[:name] = "a" * 51
      get 'delivery_create', :delivery_trader=>@delivery_trader,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee
      response.should render_template("admin/shops/delivery_new.html.erb")
    end
    
    it "テーブルに保存される" do
      trader_count = DeliveryTrader.count
      time_count = DeliveryTime.count
      fee_count = DeliveryFee.count
      get 'delivery_create', :delivery_trader=>@delivery_trader,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee
      response.should redirect_to(:action => :delivery_index)
      DeliveryTrader.count.should == trader_count+1
      DeliveryTime.count.should == time_count+DeliveryTime::MAX_SIZE
      DeliveryFee.count.should == fee_count+DeliveryFee::MAX_SIZE
      DeliveryTrader.find(:first,:order=>"id desc",:limit=>1).delivery_times.size.should == DeliveryTime::MAX_SIZE
      DeliveryTrader.find(:first,:order=>"id desc",:limit=>1).delivery_fees.size.should == DeliveryFee::MAX_SIZE
      DeliveryTrader.find(:first,:order=>"id desc",:limit=>1).delivery_fees[47].prefecture_id == nil
    end

    it "retailer_idが無効なものは登録できない" do
      delivery_trader = {:name=>"追加",:url=>"http://www.hoge.com", :retailer_id => nil}
      trader_count = DeliveryTrader.count
      time_count = DeliveryTime.count
      fee_count = DeliveryFee.count
      get 'delivery_create', :delivery_trader=>delivery_trader,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee
      response.should render_template("admin/shops/delivery_new.html.erb")
    end

    it "存在しないretailer_idは登録できない" do
      retailer_max = Retailer.find(:last).id + 100
      delivery_trader = @delivery_trader.merge({:name => "fail_trader", :retailer_id => retailer_max})
      get 'delivery_create', :delivery_trader=>delivery_trader,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee
      response.should render_template("admin/shops/delivery_new.html.erb")
    end


  end
  
  
  describe "GET 'delivery_update'" do
    fixtures :delivery_traders
    before do
      @delivery_trader = delivery_traders :witch
      
      @delivery_trader.url="http://hogehoge.com"
      @delivery_time = {}
      DeliveryTime::MAX_SIZE.times do |i|
        @delivery_time["#{i}"]={:id=>"#{i}",:name=>"午前中なら#{i}",:position=>"#{i+1}",:delivery_trader_id=>"1"}
      end
      @delivery_fee = {}
      DeliveryFee::MAX_SIZE.times do |i|
        @delivery_fee["#{i}"]={:id=>"#{i}",:price=>"#{i}",:prefecture_id=>"#{i+1}",:delivery_trader_id=>"1"}
      end
      @delivery_fee["47"][:prefecture_id]=nil
    end
    
    it "更新" do
      get 'delivery_update', :delivery_trader=>@delivery_trader.attributes,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee, :id=>@delivery_trader.id
      response.should redirect_to(:action => :delivery_index, :id => @delivery_trader.id)
    end
    
    it "更新失敗" do
      @delivery_trader[:name] = "a" * 51
      get 'delivery_update', :delivery_trader=>@delivery_trader.attributes,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee, :id=>@delivery_trader.id
      response.should render_template("admin/shops/delivery_edit.html.erb")
    end
    
    it "テーブルに上書きされる" do
      get 'delivery_update', :delivery_trader=>@delivery_trader.attributes,:delivery_time=>@delivery_time,:delivery_fee=>@delivery_fee, :id=>@delivery_trader.id
      response.should redirect_to(:action => :delivery_index, :id => @delivery_trader.id)
      delivery_trader = DeliveryTrader.find(@delivery_trader.id)
      delivery_trader.should == @delivery_trader
      
      DeliveryTime::MAX_SIZE.times do |i|
        delivery_trader.delivery_times[i].name.should == @delivery_time["#{i}"][:name]
      end
      DeliveryFee::MAX_SIZE.times do |i|
        delivery_trader.delivery_fees[i].price. == @delivery_fee["#{i}"][:price]
      end
      delivery_trader.delivery_fees[47].prefecture_id == nil
    end
  end
  
  #payment関係
  describe "GET 'payment_index'" do
    fixtures :payments
    it "should be successful" do
      get 'payment_index'
      response.should be_success
      assigns[:payments].should == Payment.find(:all,:order=>"position")
    end
  end
  
  describe "GET 'sort'" do
    fixtures :payments
    
    it "positionを上げる場合" do
      Payment.find(2).position.should == 2
      get 'up', :model => "payments", :id => 2, :return_act => "payment_list"
      Payment.find(2).position.should == 1
      response.should redirect_to(:action => "payment_list")
    end
    
    it "positionを上げる場合(これ以上あがらない)" do
      Payment.find(1).position.should == 1
      get 'up', :model => "payments", :id => 1, :return_act => "payment_list"
      Payment.find(1).position.should == 1
      response.should redirect_to(:action => "payment_list")
    end
    
    
    it "positionを下げる場合" do
      Payment.find(1).position.should == 1
      get 'down', :model => "payments", :id => 1, :return_act => "payment_list"
      Payment.find(1).position.should == 2
      response.should redirect_to(:action => "payment_list")
    end
    
    it "positionを下げる場合（これ以上下がらない）" do
      old_position= Payment.find(:first,:order=>"position desc")
      get 'down', :model => "payments", :id => old_position.id, :return_act => "payment_list"
      Payment.find(:first,:order=>"position desc").position.should == old_position.position
      response.should redirect_to(:action => "payment_list")
    end
    
  end
  
  describe "GET 'destroy'" do
    it "削除に成功する" do
      Payment.find_by_id(1).should_not be_nil
      get 'destroy', :model => "payments", :id => 1, :return_act=>"payment_list"
      Payment.find_by_id(1).should be_nil
      Payment.find_by_id(2).should_not be_nil
      response.should redirect_to(:action => "payment_list")
    end

    it "削除に失敗する場合" do
      get 'destroy', :model => "payments", :id => 100 ,:return_act=>"payment_list"
    end
  end
  
  describe "GET 'payment_new'" do
    it "should be successful" do
      get 'payment_new'
      response.should be_success
      assigns[:shop] == Payment.new
    end
  end
  
  describe "GET 'payment_create'" do
    before do
      @record = {:name => "追加", :fee => 1, :delivery_trader_id => 1}
    end
    
    it "新規作成" do
      get 'payment_create', :payment => @record
      response.should redirect_to(:action=>:payment_index)
    end
    
    it "新規作成（保存して戻る失敗）" do
      @record[:name] = ""
      get 'payment_create', :payment => @record
      response.should render_template("admin/shops/payment_new.html.erb")
    end
    
    it "テーブルに保存される" do
      payment_count = Payment.count
      get 'payment_create', :payment => @record
      response.should redirect_to(:action => :payment_index)
      Payment.count.should == payment_count+1
    end
  end
  
  describe "GET 'payment_edit'" do
    fixtures :payments
    before do
      @payment = payments :cash
    end
    it "編集" do
      get 'payment_edit', :id=>@payment.id
      response.should be_success
      assigns[:shop] == @payment
    end
  end
  
  describe "GET 'payment_update'" do
    fixtures :payments
    before do
      @record = payments :cash
      @record.lower_limit=0
      @record.upper_limit=1
    end
    
    it "更新" do
      get 'payment_update', :payment => @record.attributes, :id => @record.id
      response.should redirect_to(:action => :payment_index)
    end
    
    it "更新失敗" do
      @record[:name] = ""
      get 'payment_update', :payment => @record.attributes, :id => @record.id
      response.should render_template("admin/shops/payment_edit.html.erb")
    end
    
    
    it "テーブルに上書きされる" do
      get 'payment_update', :record => @record.attributes, :id => @record.id
      response.should redirect_to(:action => :payment_index)
      payment = Payment.find(@record.id)
      payment.should == @record
    end
    
  end
  
 # 特定商取引法
  describe "GET 'tradelaw_index'" do
    fixtures :laws
    it "should be successful" do
      get 'tradelaw_index'
      response.should be_success
      assigns[:law].should == Law.find(:first)
    end
  end
  
  describe "POST 'tradelaw_update'" do
    fixtures :laws
    before do
      @record = laws :shoutorihiki
      @record.company="販売店更新"
      @record.manager="運営責任者更新"
      @record.zipcode01="012"
      @record.zipcode02="3456"
      @record.address_city="市区町村更新"
      @record.address_detail="番地、建物、マンション名更新"
      @record.tel01 ="090"
      @record.tel02 ="0000"
      @record.tel03 ="1111"
      @record.fax01 ="080"
      @record.fax02 ="1111"
      @record.fax03 ="2222"
      @record.email="mail@kbmj.com"
      @record.url="http://www.kbmj.com/index"
      @record.prefecture_id ="2"
      @record.necessary_charge="商品代金以外の必要料金更新"
      @record.order_method="注文方法更新"
      @record.payment_method="支払方法更新"
      @record.payment_time_limit="支払期限更新"
      @record.delivery_time="引き渡し時期更新"
      @record.return_exchange="返品・交換について更新"
    end
    it "should be successful" do
      
      post 'tradelaw_update', :shop=>@record.attributes,:id=>@record.id
      response.should redirect_to(:action => 'tradelaw_index')
      law = Law.find(@record.id)
      law.should == @record
      
    end
  end
  
  #メール設定
  describe "GET 'mail_index'" do
    it "should be successful" do
      get 'mail_index'
      response.should be_success
      assigns[:shop] == MailTemplate.new
    end
  end
  
  describe "POST 'mail_update'" do
    fixtures :mail_templates
    before do
      @record = mail_templates :template1
      @record.title="タイトル更新"
      @record.header="ヘッダー更新"
      @record.footer="フッター更新"
    end
    it "should be successful" do 
      post 'mail_update', :mail => @record.attributes
      response.should redirect_to(:action => 'mail_index')
      mail_template = MailTemplate.find(@record.id)
      mail_template.should == @record
    end
  end
  
  describe "POST 'mail_search'" do
    fixtures :mail_templates
    before do
      @record = mail_templates :template1
    end

    it "with id" do
      post 'mail_search', :id => @record.id
      assigns[:mail].should == @record
      response.should render_template("admin/shops/_mail_form")
    end

    it "without id" do
      post 'mail_search'
      assigns[:mail].id.should be_nil
      response.should render_template("admin/shops/_mail_form")
    end
  end

  #SEO設定
  describe "GET 'seo_index'" do
    it "should be successful" do
      get 'seo_index'
      response.should be_success
      assigns[:shop] == Seo.find(:all,:order=>"page_type")
    end
  end
  
  describe "POST 'seo_update'" do
    fixtures :seos
    before do
      @record = seos :top
      @record.name=Seo::TYPE_NAMES[@record.page_type]
      @record.author="author更新"
      @record.description="description更新"
      @record.keywords="keywords更新"
    end
    it "should be successful" do
      
      post 'seo_update', :seo=>@record.attributes
      response.should redirect_to(:action => 'seo_index')
      seo = Seo.find_by_page_type(@record.page_type)
      seo.should == @record
      
    end
  end
  
    #会員規約設定
  describe "GET 'kiyaku_index'" do
    it "should be successful" do
      get 'kiyaku_index'
      response.should be_success
      assigns[:shops] == Kiyaku.find(:all)
      assigns[:kiyaku] == Kiyaku.new
    end
  end
  
  describe "GET 'kiyaku_index' 編集" do
    fixtures :kiyakus
    before do
      @kiyaku = kiyakus :kiyaku1
    end
    it "編集" do
      get 'kiyaku_index', :id=>@kiyaku.id
      response.should be_success
       assigns[:shops] == Kiyaku.find(:all)
      assigns[:kiyaku] == @kiyaku
    end
  end
  describe "GET 'sort'" do
    
    it "positionを上げる場合" do
      Kiyaku.find(2).position.should == 2
      get 'up', :model => "kiyakus", :id => 2, :return_act => "kiyaku_index"
      Kiyaku.find(2).position.should == 1
      response.should redirect_to(:action => "kiyaku_index")
    end
    
    it "positionを上げる場合(これ以上あがらない)" do
      Kiyaku.find(1).position.should == 1
      get 'up', :model => "kiyakus", :id => 1, :return_act => "kiyaku_index"
      Kiyaku.find(1).position.should == 1
      response.should redirect_to(:action => "kiyaku_index")
    end
    
    
    it "positionを下げる場合" do
      Kiyaku.find(1).position.should == 1
      get 'down', :model => "kiyakus", :id => 1, :return_act => "kiyaku_index"
      Kiyaku.find(1).position.should == 2
      response.should redirect_to(:action => "kiyaku_index")
    end
    
    it "positionを下げる場合（これ以上下がらない）" do
      Kiyaku.find(3).position.should == 3
      get 'down', :model => "kiyakus", :id => 3, :return_act => "kiyaku_index"
      Kiyaku.find(3).position.should == 3
      response.should redirect_to(:action => "kiyaku_index")
    end
    
  end
  
  describe "GET 'destroy'" do
    it "削除に成功する" do
      get 'destroy', :model => "kiyakus", :id => 1,:return_act=>"kiyaku_index"
      Kiyaku.find(:first).id.should == 2
      response.should redirect_to(:action => "kiyaku_index")
    end
    it "削除に失敗する場合" do
      get 'destroy', :model => "kiyakus", :id => 100 ,:return_act=>"kiyaku_index"
    end
  end
  
  describe "POST 'kiyaku_create'" do
    before do
      @record = {:name=>"追加",:content=>"追加追加"}
    end
    
    it "新規作成" do
      get 'kiyaku_create', :kiyaku => @record
      response.should redirect_to(:action => :kiyaku_index)
    end
    
    it "新規作成（保存して戻る失敗）" do
      @record[:name] = ""
      get 'kiyaku_create', :kiyaku => @record
      response.should render_template("admin/shops/kiyaku_index.html.erb")
    end
    
    it "テーブルに保存される" do
      kiyaku_count = Kiyaku.count
      get 'kiyaku_create', :kiyaku => @record
      response.should redirect_to(:action=>:kiyaku_index)
      Kiyaku.count.should == kiyaku_count+1
    end
  end
  describe "POST 'kiyaku_update'" do
    fixtures :kiyakus
    before do
      @record = kiyakus :kiyaku1
      @record.name="タイトル更新"
      @record.content="内容更新"
    end

    it "should be successful" do  
      post 'kiyaku_update', :kiyaku => @record.attributes
      response.should redirect_to(:action => 'kiyaku_index')
      kiyaku = Kiyaku.find(@record.id)
      kiyaku.should == @record
    end
  end

  describe "GET 'point_index'" do
    it "should be successful" do
      get 'point_index'
      response.should be_success
      assigns[:shop].should == Shop.find(:first)
    end
  end

  describe "POST 'point_update'" do
    before do
      @shop = {:point_granted_rate => "", :point_at_admission => ""}
      @id = Shop.find(:first).id
    end

    it "更新" do
      post 'point_update', :id => @id, :shop => @shop
      response.should redirect_to(:action => :point_index)
    end

    it "idが無い場合" do
      post 'point_update'
      response.should render_template("admin/shops/point_index.html.erb")
    end

    it "更新失敗" do
      @shop[:point_granted_rate] = "test"
      post 'point_update', :id => @id, :shop => @shop
      response.should render_template("admin/shops/point_index.html.erb")
    end
  end

  describe "GET 'privacy'" do
    fixtures :privacies
    it "should be successful" do
      privacy = privacies :one
      get 'privacy'
      assigns[:privacy].attributes.should == privacy.attributes
    end
  end

  describe "POST 'privacy_update'" do
    before(:each) do
      @privacy = {:content_collect=>"テスト1",:content_collect_mobile=>"テスト2",:content_privacy=>"テスト3",:content_privacy_mobile=>"テスト4"}
    end    
    fixtures :privacies
    it "更新" do
      post 'privacy_update', :privacy => @privacy
      response.should redirect_to(:action => :privacy)
    end

    it "POSTではなくGETでアクセス" do
      get 'privacy_update', :privacy => @privacy
      flash[:notice].should be_nil
      response.should redirect_to(:action => :privacy)
    end
  end

end
