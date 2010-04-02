require File.dirname(__FILE__) + '/../spec_helper'

describe CartController do
  fixtures :systems, :customers, :carts, :products, :product_styles, :styles,
           :delivery_traders, :delivery_times, :payments, :delivery_addresses,
           :delivery_fees, :order_deliveries, :shops

  before do
    @dummy_carts = [carts(:cart_can_incriment).attributes]
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use CartController" do
    controller.should be_an_instance_of(CartController)
  end


  describe "GET 'show'" do
    it "should be successful" do
      session[:carts] = nil
      get 'show'
      response.should be_success
    end
    
    it "カートが空の場合" do
      session[:carts] = nil
      get 'show'
      response.should be_success
      assigns[:carts].should be_empty
    end
    
    it "カートが空ではない場合" do
      session[:carts] = [carts(:cart_can_incriment)].map(&:attributes)
      get 'show'
      response.should be_success
      assigns[:carts].should_not be_empty
      assigns[:cart_point].should_not be_nil
    end

    #it 'ログイン状態の時、カートは DB から取得' do
    #  customer = customers(:product_buyer)
    #  session[:customer_id] = customer.id
    #  get 'show'
    #  assigns[:carts].should == Customer.find(customer.id).carts
    #end

    #it 'ログイン状態の時、セッションにあるカートは削除' do
    #  customer = customers(:product_buyer)
    #  session[:customer_id] = customer.id
    #  session[:carts] = [carts(:cart_can_incriment)].map(&:attributes)
    #  get 'show'
    #  session[:carts].should be_nil
    #end

    it 'ログイン状態の時もカートはセッションに保持' do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      carts = [carts(:cart_can_incriment)]
      session[:carts] = carts.map(&:attributes)
      get 'show'
      assigns[:carts].zip(carts).each do |actual, expected|
        actual.product_style_id.should == expected.product_style_id
        actual.quantity.should == expected.quantity
      end
    end

    it '非ログイン状態の時、カートはセッションから取得' do
      session[:customer_id] = nil
      carts = [carts(:cart_can_incriment)]
      session[:carts] = carts.map(&:attributes)
      get 'show'
      assigns[:carts].zip(carts).each do |actual, expected|
        actual.product_style_id.should == expected.product_style_id
        actual.quantity.should == expected.quantity
      end
    end

    it '非ログイン状態でまだ買い物をしていない時、カートは空' do
      session[:customer_id] = nil
      session[:carts] = nil
      get 'show'
      assigns[:carts].should_not be_nil
      assigns[:carts].should be_empty
    end
  end

  describe "GET 'inc'" do
    it "should be successful" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_incriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'inc', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
    end
    
    it "商品を加算できる場合" do
      session[:customer_id] = nil
      carts = [carts(:cart_can_incriment)]
      session[:carts] = carts.map(&:attributes)
      get 'inc', {:id => carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      assigns[:carts][0].quantity.should == carts[0].quantity + 1
    end
    
    it "商品を加算できない場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_not_incriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'inc', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      Cart.find(@carts[0].id).quantity.should_not == 2
    end
  end

  describe "GET 'dec'" do
    it "should be successful" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_decriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'dec', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
    end
    
    it "商品を減算し、0個とならない場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_decriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'dec', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      assigns[:carts][0].quantity.should == @carts[0].quantity - 1
    end
    
    it "商品を減算し、0個となる場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_not_decriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'dec', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      assigns[:carts].should_not be_empty
      assigns[:carts][0].quantity.should == 1
    end
  end

  describe "GET 'delete'" do
    it "should be successful" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_incriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'delete', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
    end
    
    it "商品を取り消した際、カートが空になる場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_incriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'delete', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      assigns[:carts].should be_empty
    end
    
    it "商品を取り消した際、カートが空にならない場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      @carts = [carts(:cart_can_incriment), carts(:cart_can_not_incriment)]
      session[:carts] = @carts.map(&:attributes)
      get 'delete', {:id => @carts[0].product_style_id}
      response.should be_redirect
      response.should redirect_to({:controller => 'cart', :action => 'show'})
      assigns[:carts].should_not be_empty
    end
  end

  describe "GET 'shipping'" do
    before do
      session[:carts] = @dummy_carts
    end

    it "should be successful" do
      session[:customer_id] = customers(:product_buyer).id
      get 'shipping'
      response.should be_success
    end

    it "セッションにユーザが無い場合" do
      session[:customer_id] = nil
      get 'shipping'
      response.should redirect_to(:controller => 'accounts', :action => 'login')
    end
  end

  describe "GET 'purchase'" do
    before do
      session[:customer_id] = customers(:product_buyer).id
    end
    it "GET 禁止" do
      session[:customer_id] = Customer.first.id
      session[:carts] = @dummy_carts
      get 'purchase'
      response.should_not be_success
    end
  end

  describe "POST 'purchase'" do
    before do
      @customer = customers(:have_delivary_address)
      session[:customer_id] = @customer.id
      @temporary_customer = {
        :first_name => '非会', :family_name => '員衛門',
        :first_name_kana => 'ア', :family_name_kana => 'イ',
        :prefecture_id => '1',
        :zipcode01 => '999', :zipcode02 => '9999',
        :address_city => '市', :address_detail => '丁目',
        :tel01 => '001', :tel02 => '0002', :tel03 => '0003',
        :email => 'udon@noodle.com',
        :sex => System::MALE
      }
      @optional_address = {
        :first_name => '配送先', :family_name => '住所',
        :first_name_kana => 'ア', :family_name_kana => 'イ',
        :prefecture_id => '1',
        :zipcode01 => '999', :zipcode02 => '9999',
        :address_city => '市', :address_detail => '丁目',
        :tel01 => '001', :tel02 => '0002', :tel03 => '0003'
      }
      session[:carts] = @dummy_carts
      delivery_address = DeliveryAddress.find(delivery_addresses(:optional_address3).id)      
      delivery_address.customer_id = customers(:have_delivary_address).id
      delivery_address.save!
    end

    # 配送先住所
    it "会員・会員登録住所を使用" do
      post 'purchase', :address_select => '0'
      assigns[:delivery_address].attributes.each do | name, value |
        value.should == @customer.basic_address[name]
      end
    end
    it "会員・追加登録住所を使用" do
      da = @customer.delivery_addresses[0]
      post 'purchase', :address_select => da.id
      assigns[:delivery_address].attributes.each do | name, value |
        value.should == @customer.delivery_addresses[0][name]
      end
    end

    it "@order_delivery があること" do
      post 'purchase', :address_select => 0
      response.should be_success
      assigns[:order_delivery].should_not be_nil
    end

    it "@order_delivery があること" do
      od = order_deliveries(:nobi)
      post 'purchase', :order_delivery => od.attributes
      response.should be_success
      assigns[:order_delivery].should_not be_nil
      assigns[:order_delivery].payment_id.should be_nil
      assigns[:order_delivery].delivery_time_id.to_i.should == od.delivery_time_id
      assigns[:order_delivery].message.should == od.message
    end

    it "住所を取得できない場合はエラー" do
      post 'purchase', :address_select => 999999
      assigns[:delivery_address].should be_nil
      response.should_not be_success
    end
  end

  describe "GET 'confirm'" do
    it "GET 禁止" do
      get 'confirm'
      response.should_not be_success
    end
  end

  describe "POST 'confirm'" do
    before do
      session[:carts] = [carts(:cart_by_have_cart_user_one)].map(&:attributes)
      delivery_address = delivery_addresses(:optional_address)
      order_delivery = order_deliveries(:nobi)
      @params = {
        :point_usable => 'false',
        :delivery_address => delivery_address.attributes,
        :order_delivery => order_delivery.attributes
      }
    end

    it "小計" do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      post 'confirm', @params
      assigns[:cart_price].should_not be_nil
    end

    it "送料" do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      post 'confirm', @params
      assigns[:order_delivery].deliv_fee.should_not be_nil
    end

    it "手数料" do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      post 'confirm', @params
      assigns[:order_delivery].charge.should_not be_nil
    end

    it "合計" do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      post 'confirm', @params
      assigns[:order_delivery].total.should_not be_nil
    end

    it "配送先情報" do
      customer = customers(:product_buyer)
      session[:customer_id] = customer.id
      post 'confirm', @params
      assigns[:order_delivery].first_name.should_not be_nil
      assigns[:order_delivery].family_name.should_not be_nil
      assigns[:order_delivery].first_name_kana.should_not be_nil
      assigns[:order_delivery].family_name_kana.should_not be_nil
      assigns[:order_delivery].tel01.should_not be_nil
      assigns[:order_delivery].tel02.should_not be_nil
      assigns[:order_delivery].tel03.should_not be_nil
      assigns[:order_delivery].zipcode01.should_not be_nil
      assigns[:order_delivery].zipcode02.should_not be_nil
      assigns[:order_delivery].prefecture_id.should_not be_nil
      assigns[:order_delivery].address_city.should_not be_nil
      assigns[:order_delivery].address_detail.should_not be_nil
    end
  end

  describe "POST 'complete'" do
    before do
      Notifier.stub!(:deliver_buying_complete).and_return(nil)
      @customer = customers(:product_buyer)
      session[:customer_id] = @customer.id
      session[:carts] = @customer.carts.map(&:attributes)

      order_delivery = order_deliveries(:nobi)
      @params = {
        :point_usable => 'false',
        :order_delivery => order_delivery.attributes
      }
    end

    it "should be successful" do
      post 'complete', @params
      flash[:error].should be_nil
      response.should_not redirect_to(:action => :show)
    end

#    it "戻るボタン" do
#      post 'complete', :cancel => 'zzz'
#      response.should render_template('purchase')
#    end

    it "カート内容が無効(個数超過等)" do
      session[:carts] = [carts(:invalid).attributes]
      post 'complete', @params
      response.should redirect_to(:action => :show)
    end

    it "should not be successful" do
      @params[:order_delivery] = {}
      post 'complete', @params
      response.should render_template('purchase')
    end
#
#    it "should not be successful" do
#      @params[:order_delivery] = {}
#      post 'complete', @params
#      response.should render_template('purchase')
#    end

    it "受注の中身" do
      post 'complete', @params
      assigns[:order].should_not be_nil
      assigns[:order].customer_id.should == @customer.id
      assigns[:order].received_at.should_not be_nil
      assigns[:order].should have(1).order_deliveries
    end

    it 'カートをクリアする' do
      post 'complete', @params
      assigns[:cart].should be_blank
    end

    it 'メールを送る' do
      post 'complete', @params
      flash[:order_id].should == assigns[:order].id
    end
  end

  describe "GET 'finish'" do
    it "should be successful" do
      flash[:completed] = true
      get 'finish', :ids => ["5"]
      response.should be_success
    end
  end

  describe "GET 'add_product'" do
    it "should be successful" do
      get 'add_product', {:product_id => 8, :size => 2, :style_category_id1 => 40}
      response.should redirect_to(:action => 'show')
    end

    it "存在しない商品" do
      get 'add_product', {:product_id => 8, :style_category_id1 => 90000, :size=>1}
      flash[:cart_add_product].should_not be_nil
    end

    it "カートが空で、購入可能な商品をカートに入れる場合" do
      session[:carts] = nil
      get 'add_product', {:product_id => 8, :size => 1, :style_category_id1 => 40}
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 1
    end

    it "カートが空で、購入可能な個数を超過して商品をカートに入れる場合" do
      session[:carts] = nil
      get 'add_product', {:product_id => 8, :size => 20, :style_category_id1 => 40}
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 1
    end

    it "カートが空ではなく、購入可能な商品をカートに入れる場合" do
      session[:carts] = [carts(:cart_can_incriment)].map(&:attributes)
      get 'add_product', {:product_id => 8, :size => 1, :style_category_id1 => 40}
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 2
    end

    it "カートが空ではなく、購入可能な個数を超過して商品をカートに入れる場合" do
      session[:carts] = [carts(:cart_can_incriment)].map(&:attributes)
      get 'add_product', {:product_id => 8, :size => 30, :style_category_id1 => 40}
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 2
    end

    it "既にカートにある商品をカートに入れる場合、個数を増やす" do
      session[:customer_id] = nil # customers(:product_buyer).id
      carts = [carts(:cart_can_incriment), carts(:cart_can_decriment)]
      session[:carts] = carts.map(&:attributes)
      product_style = carts[0].product_style
      get 'add_product', {:size => 1,
        :product_id => product_style.product_id,
        :style_category_id1 => product_style.style_category_id1,
        :style_category_id2 => product_style.style_category_id2
      }
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 2
    end

    # 商品に規格が2つ以上ある場合
    it "style_category_id1とstyle_category_id2両方を指定した場合" do
      session[:customer_id] = nil # customers(:product_buyer).id
      session[:carts] = [carts(:cart_have_classcategory2), carts(:cart_can_decriment)].map(&:attributes)
      get 'add_product', {:product_id => 7, :size => 1, :style_category_id1 => 30, :style_category_id2 => 50}
      response.should redirect_to(:action => 'show')
      assigns[:carts].should_not be_empty
      assigns[:carts].size.should == 2
    end
  end
end
