# -*- coding: utf-8 -*-
require 'timeout'
require 'open-uri'
class CartController < BaseController
  include CartControllerExtend

  ssl_required :temporary_shipping, :shipping, :delivery, :delivery2, :purchase, :purchase2, :purchase_confirm, :confirm, :complete, :before_finish, :finish, :select_delivery_time, :select_delivery_time_with_delivery_trader_id_ajax

  before_filter :cart_check, :only => [:temporary_shipping,:shipping, :purchase,:purchase2, :confirm, :complete, :delivery, :delivery2]
  before_filter :login_divaricate ,:only =>[:purchase,:purchase2,:confirm, :complete, :delivery, :delivery2]
  before_filter :login_check, :only => [:shipping]
  before_filter :force_post, :only => [:delivery, :purchase,:purchase2,:confirm, :complete]
  after_filter :save_carts
  before_filter :verify_session_token, :except => :select_delivery_time
  
  CARTS_MAX_SIZE = 20
  DENA_AFFILIATE_URL = 'http://smaf.jp/req.cgi'

  # カートの中を見る。Loginの可否、カート内容の有無で動的に変動。カート操作全般はここから行う。
  def show
    unless @carts.all?(&:valid?)
      if flash.now[:error]
        flash.now[:error] = flash.now[:error] + cart_errors(@carts)
      else
        flash.now[:error] = cart_errors(@carts)
      end
    end
    @cart_point = total_points
    if @carts.last
      @recommend_for_you = Recommend.recommend_get(@carts.last.product_id, Recommend::TYPE_VIEW)
    end
  end

=begin rdoc
  * INFO

    parametors:
     :value             => Fixnum[デフォルト値: 1]
     :product_id        => Fixnum[必須]
     :classcategory_id1 => Fixnum[必須ではない]
     :classcategory_id2 => Fixnum[必要ではない]

     return:
       カート内の商品の個数を [value]分加算する
       規格分類1または規格分類2が指定された場合は、指定された規格分類の個数を加算する
       規格分類1と規格分類2が指定された場合は、両方の規格分類を持つ商品の個数を加算する
       規格分類が指定されない場合は、商品の個数を加算する
       加算できない場合は、加算しない
=end
  def inc
    # TODO キーはインデックスにしたい: そのほうがユーザ視点で自然なので。
    value = params[:value] || 1
    cart = find_cart(:product_style_id => params[:id].to_i)
    if cart.nil? || cart.product_style.nil?
      redirect_to :action => :show
      return
    end
    new_quantity = cart.quantity + value
    cart.quantity = cart.product_style.available?(new_quantity)
    if cart.quantity < new_quantity
      flash[:notice] = '購入できる上限を超えています'
    end
    redirect_to :action => 'show'
  end

=begin rdoc
  * INFO

    parametors:
     :value      => Fixnum[デフォルト値: 1]
     :product_id => Fixnum[必須]

     return:
       カート内の商品の個数を [value]分減算する
       減算した結果、商品の個数が 0 以下となる場合は 1 個にする
=end
  def dec
    value = params[:value] || 1
    cart = find_cart(:product_style_id => params[:id].to_i)
    if cart.nil? || cart.product_style.nil?
      redirect_to :action => :show
      return
    end
    new_quantity = cart.quantity - value
    if new_quantity <= 1  then
      new_quantity = 1
    end
    cart.quantity = new_quantity
    redirect_to :action => 'show'
  end

=begin rdoc
  * INFO

    parametors:
     :product_style_id => Fixnum[必須]

     return:
       カートを削除する
=end
  def delete
    # セッションから消す
    cart = find_cart(:product_style_id => params[:id].to_i)
    if cart.nil?
      redirect_to :action => :show
      return
    end
    @carts.reject!{|i|i==cart}
    # 保存されていれば DB から消す
    cart.destroy unless cart.new_record?
    redirect_to :action => 'show'
  end

  #会員購入のお届け先指定画面
  def shipping
    unless @carts.all?(&:valid?)
      redirect_to :action => :show
      return
    end
    cookies[:back_from_deliv] = {
      :value => url_for({:controller => 'cart', :action => 'shipping'}),
      :expires => 30.minutes.from_now
    }
    if @login_customer
      @address_size = DeliveryAddress.count(:conditions => ["customer_id =?", @login_customer.id])
      @addresses = DeliveryAddress.find(:all, :conditions => ["customer_id =?", @login_customer.id], :include => :customer)
      basic_address = @login_customer.basic_address
      @addresses.unshift(basic_address) if basic_address
    end
  end

  #非会員購入
  def temporary_shipping
    unless @carts.all?(&:valid?)
      redirect_to :action => :show
      return
    end
     @temporary_customer = Customer.new(params[:temporary_customer])
     @optional_address = DeliveryAddress.new(params[:optional_address])
     #戻るボタンから戻る時
      if params[:back] == "1"
        logger.debug params[:order_deliveries]["1"]
        convert(params[:order_deliveries].first[1])
     end
  end
 
  def delivery
    cookies.delete :back_from_deliv if cookies[:back_from_deliv]

    #2.配送先の情報を取ってくる
    if @login_customer
      # 会員の場合
      if params[:address_select].to_i.zero?
        # 会員登録住所を使う
        @delivery_address = @login_customer.basic_address
      else
        # 選ばれた配送先を使う
        @delivery_address = DeliveryAddress.find_by_id_and_customer_id(params[:address_select], @login_customer.id)
      end
    elsif @not_login_customer
      # 非会員
      @temporary_customer = Customer.new(params[:temporary_customer])
      @temporary_customer.from_cart = true
      
      # お届け先
      #if params[:address_enable].nil?
        @optional_address = DeliveryAddress.new(params[:optional_address])
      #end
      
      # 確認画面から戻る時
      if params[:back] == "1"
        convert(params[:order_deliveries].first[1])
      end
      # 入力チェック
      # メールアドレス重複チェックを除き
      @temporary_customer.activate = Customer::HIKAIIN
      if !@temporary_customer.valid? or
       (params[:address_enable].nil? and !@optional_address.valid?)
        @error_back = true
        render :action => "temporary_shipping"
        return
      end
      
      # お届け先設定
      if params[:address_enable].nil?
        @delivery_address = @optional_address        
      else
        @delivery_address = @temporary_customer.basic_address  
      end
    end
    
    # 住所を取得できないと、この先困るので、どこかに飛ばす
    return redirect_to(:action => 'show') unless @delivery_address

    @order_deliveries = Hash.new
    unless params[:order_deliveries].nil?
      params[:order_deliveries].each do |key, order_delivery|
        @order_deliveries[key] = OrderDelivery.new(order_delivery)
      end
    end
    if @order_deliveries.empty?
      @carts.map(&:product_style).map(&:product).map(&:retailer).each do |retailer|
        od = OrderDelivery.new
        od.set_delivery_address(@delivery_address)
        @order_deliveries[retailer.id] = od
      end
    end
    @delivery_traders = Hash.new
    @carts.map(&:product_style).map(&:product).map(&:retailer).each do |retailer|
      @delivery_traders[retailer.id] = select_delivery_trader_with_retailer_id(retailer.id)
    end
    if @not_login_customer
      @order_deliveries.each do |key, order_delivery|
        order_delivery.set_customer(@temporary_customer)
      end
    end
    render :action => 'delivery'
  end

  #TODO テストケースの作成
  def delivery2
    @order_deliveries = Hash.new
    unless params[:order_deliveries].nil?
      params[:order_deliveries].each do |key, order_delivery|
        @order_deliveries[key] = OrderDelivery.new(order_delivery)
      end
    else
      #error
    end
    @delivery_time_options = Hash.new
    @order_deliveries.each do |retailer_id, od|
      if od.delivery_trader_id.blank?
        flash.now[:error] = "発送方法が選択されていません"
        delivery
        return
      end
      delivery_trader_id = od.delivery_trader_id
      option = select_delivery_time_with_delivery_trader_id(delivery_trader_id)
      @delivery_time_options[retailer_id] = option
    end
    render :action => 'delivery2'
  end

  # Order を作る
  def purchase
    @order_deliveries = Hash.new
    unless params[:order_deliveries].nil?
      params[:order_deliveries].each do |key, order_delivery|
        @order_deliveries[key] = OrderDelivery.new(order_delivery)
      end
    else
      #error
    end

    @order_deliveries.each do |key, value|
      if value.delivery_trader_id.blank? 
        flash.now[:error] = "発送方法が選択されていません"
      elsif value.delivery_time_id.blank?
        flash.now[:error] = "配達時間が選択されていません"
      end
      if flash.now[:error]
        if request.mobile? && !request.mobile.respond_to?('smartphone?')
          delivery2
        else
          params[:back] = "1"
          delivery
        end
        return
      end
    end

    if params[:back] == "1"
      @payment_id = @order_deliveries.first[1].payment_id
    end

    render :action => 'purchase'
  end
  
  #モバイルお届け時間選択
  #現在未使用
  def purchase2
    @order_delivery = OrderDelivery.new(params[:order_delivery])
    unless @order_delivery.valid?
      if params[:point_check] == "true"
        @point_check = true
      end      
      render :action => 'purchase'
      return
    end
    # ポイントチェック
    if @login_customer
      if params[:point_check] == "true"
        @point_check = true
        use_point = @order_delivery.use_point.to_i
        if use_point == 0
           flash.now[:error] = '使用ポイントをご入力ください。 '
           render :action => 'purchase'
           return
        end        
        # ポイントの使いすぎをチェック
        if use_point > @cart_price
          flash.now[:error] = 'ご利用ポイントがご購入金額を超えています。'
          render :action => 'purchase'
          return
        end
        if use_point > @login_customer.point.to_i
          flash.now[:error] = 'ご利用ポイントが所持ポイントを超えています。'
          render :action => 'purchase'
          return
        end
      else
        @point_check = false
        @order_delivery.attributes = {:use_point => 0}
      end  
    end
    #選択したお支払方法によりお届け時間取得
    select_delivery_time
    @order_delivery.target_columns = params[:order_delivery].keys.map(&:to_s)
  end
 
  def select_delivery_time_with_delivery_trader_id_ajax
    delivery_trader_id = params[:delivery_trader_id]
    @options = select_delivery_time_with_delivery_trader_id(delivery_trader_id)
    render :layout => false unless request.mobile? && !request.mobile.respond_to?('smartphone?')
  end


  # AJAXお届け時間取得
  def select_delivery_time
    h = params[:order_delivery] || params
    payment_id = h[:payment_id]
    @selected = h[:delivery_time_id]
    delivery_times = DeliveryTime.find(
      :all, :conditions => ["payments.id=? and delivery_times.name <> ''", payment_id],
      :include => [:delivery_trader=>:payments], :order => 'delivery_times.position')
    @options = [['指定なし', nil]]
    @options.concat(delivery_times.map do |dt|
      [dt.name, dt.id]
    end)
    render :layout => false unless request.mobile?
  end

  #確認画面へ
  def confirm
    init_order_deliveries
    if params[:order_delivery].nil? || params[:order_delivery][:payment_id].blank?
      flash.now[:error] = "支払い方法が選択されていません"
      render :action => 'purchase'
      return
    end
    @order_deliveries.each do |key, od|
      unless od.valid?
        render :action => 'purchase'
        return
      end
    end

    if @login_customer
      @all_use_point = 0
      @order_deliveries.each do |retailer_id, od|
        if !params[:points].nil? && !params[:points][retailer_id].nil? && params[:points][retailer_id][:point_check] == "true"
          use_point = od.use_point.to_i
          if use_point <= 0
            flash.now[:error] = '使用ポイントをご入力ください。'
            render :action => 'purchase'
            return
          end
          if use_point > @cart_price_map[retailer_id.to_i].to_i
            flash.now[:error] = 'ご利用ポイントがご購入金額を超えています。'
            render :action => 'purchase'
            return
          end
          @all_use_point = @all_use_point + use_point
        else
          od.use_point = 0
        end
        if @all_use_point > @login_customer.point.to_i
          flash.now[:error] = 'ご利用ポイントが所持ポイントを超えています。'
          render :action => 'purchase'
          return
        end
        
        od.attributes = {:add_point => total_points_each_cart(@carts_map[retailer_id.to_i])} 
      end
      @cart_point = total_points
      @point_after_operation = @login_customer.point.to_i - @all_use_point + @cart_point
      session[:point_after_operation] = @point_after_operation
    end
    
    @payment_total = 0
    @order_deliveries.each do |retailer_id, od |
      od.calculate_charge!
      od.calculate_total!
      @payment_total = @payment_total + od.payment_total
    end

    @next = :complete
    render :action => 'confirm'
  end

  #完了画面
  def complete
    unless @carts.all?(&:valid?)
      redirect_to :action => :show
      return
    end
    @login_customer.point = session[:point_after_operation] if @login_customer
    @orders = Hash.new
    @order_deliveries = Hash.new
    @order_details = Hash.new
    @ids = Array.new
    params[:order_deliveries].each do |key, _od|
      order = nil
      if @not_login_customer
        order = Order.new
      else
        order = @login_customer.orders.build
      end
      order.retailer_id = key.to_i
      order.received_at = DateTime.now
      od = order.order_deliveries.build(_od)
      od.set_customer(@login_customer) if @login_customer
      od.status = OrderDelivery::JUTYUU
      @orders[key] = order
      @order_deliveries[key] = od
      cart = @carts_map[key.to_i]
      @order_details[key] = od.details_build_from_carts(cart)
      od.calculate_charge!
      od.calculate_total!
      @ids << @order_details[key].map{|o_d| o_d.product_style.product_id}
    end  

    @order_deliveries.each do |key, od|
      unless od.valid? and @order_details[key].all?(&:valid?)
        render :action => 'purchase'
        return 
      end
    end

    if @order_deliveries.empty? or @order_details.empty?
      render :action => 'purchase'
      return
    end

    # paymentロジックをプラグイン化するため、予めセッションに保存しておき画面遷移で引き回さないようにする
    save_transaction_items_before_payment
    payment_id =  @order_deliveries.first[1].payment_id
    payment = Payment.find(payment_id)
    #p "plugin_id: " + payment.payment_plugin_id.to_s
    payment_plugin = payment.get_plugin_instance
    #p payment_plugin.name
    self.send payment_plugin.next_step(current_method_symbol)
  end
  def before_finish
    unless restore_transaction_items_after_payment
      flash.now[:error] = '失敗しました'
      redirect_to :action => 'show'
      return
    end
    begin
      save_before_finish
    rescue => e
      flash.now[:error] = 'データの保存に失敗しました。商品の在庫が切れた可能性があります。'
      logger.error(e.message)
      e.backtrace.each{|s|logger.error(s)}
      redirect_to :action => 'show'
      return
    end
    redirect_to :action => :finish, :ids => @ids
    
  end


  def finish
    unless flash[:completed]
      render :template => 'cart/405', :status => :method_not_allowed
      return
    end
    session[:point_after_operation] = nil
    session[:transaction_items] = nil
    @recommend_buys = Recommend.recommend_get(params[:ids][0], Recommend::TYPE_BUY)
    @shop = Shop.find(:first)
    render :action => 'complete'
  end

=begin rdoc
  * INFO

    parametors:
      :product_style_id => Fixnum[必須ではない]
      :product_id => Fixnum[必須]
      :style_category_id1  => Fixnum[必須ではない]
      :style_id2  => Fixnum[必須ではない]
      :size       => Fixnum[必須]

    return:
      セッションに保持しているカートに、商品を追加する
      セッションにカートを保持していない場合は、カートそのものを新たに所持する
      既にカートに同じ商品がある場合は、カート内の商品の個数を [size] 分だけ加算する
      [size] が購入可能な上限数を超過する場合、購入可能な上限数までカートへ入れ、
      購入制限により購入できない、とする旨のメッセージを返す。
      購入できない商品の場合は、カートに入れない
=end
  def add_product
    @add_product = CartAddProductForm.new(params)
    unless @add_product.valid?
      flash[:cart_add_product] = @add_product.errors.full_messages
      if @add_product.product_id
        flash['error_%d' % @add_product.product_id] = flash[:cart_add_product]
      end
      request.env['HTTP_REFERER'] ||= url_for(:action=>:show)
      redirect_to :back
      return
    end
    @carts ||= []
    product_style =
      if params[:product_style_id]
        ProductStyle.find_by_id(params[:product_style_id].to_i)
      else
        ProductStyle.find_by_product_id_and_style_category_id1_and_style_category_id2(params[:product_id], params[:style_category_id1], params[:style_category_id2])
      end

    if product_style.nil?
      flash[:cart_add_product] = "ご指定の商品は購入できません。"
      request.env['HTTP_REFERER'] ||= url_for(:action=>:show)
      redirect_to :back
      return
    end

    cart = find_cart(:product_style_id => product_style.id)
    if cart.nil?
      if @carts.size >= CARTS_MAX_SIZE
        flash[:cart_add_product] = '一度に購入できる商品は ' + "#{CARTS_MAX_SIZE}" + '種類までです。'
        redirect_to :action => 'show'
        return
      end
      cart = Cart.new(:product_style => product_style,
                      :customer => @login_customer,
                      :quantity => 0)
      @carts << cart
    end
    # キャンペ
    unless params[:campaign_id].blank?
      cart.campaign_id = params[:campaign_id]
    end

    size = [params[:size].to_i, 1].max
    # 購入可能であれば、カートに商品を追加する
    insert_size = product_style.available?(cart.quantity + size)
    incremental = insert_size - cart.quantity # 増分
    product_name = product_style.full_name
    if insert_size.to_i <= 0
      # 購入可能な件数が 0 より小さい場合はカートを追加しない
      @carts.delete(cart)
      flash[:cart_add_product] = "「#{product_name}」は購入できません。"
    elsif incremental < size
      # 指定数の在庫が無かった
      flash[:cart_add_product] = "「#{product_name}」は販売制限しております。一度にこれ以上の購入はできません。"
    end
    cart.quantity = insert_size
    session[:cart_last_product_id] = product_style.product_id
    redirect_to :action => 'show'
  end

  private

  def save_before_finish
    Order.transaction do
      @carts.each do | cart |
        if request.mobile?
          ProductAccessLog.create(:product_id => cart.product_style.product_id,
                                  :session_id => session.session_id,
                                  :customer_id => @login_customer && @login_customer.id,
                                  :docomo_flg => request.mobile == Jpmobile::Mobile::Docomo,
                                  :ident => request.mobile.ident,
                                  :complete_flg => true)
        end
        product_style = ProductStyle.find(cart.product_style_id, :lock=>true)
        product_style.order(cart.quantity)
        product_style.save!
        #会員のみキャンペーン処理
        if @login_customer
          cart.campaign_id and process_campaign(cart, @login_customer)  
        end
      end
      # 非会員購入対応
      if @login_customer
        @login_customer.carts.delete_all
        @login_customer.save!
      end
      
      order_ids = Hash.new
      @orders.each do |key, order|
        order.save!
        order_ids[key] = order.id
        Notifier::deliver_buying_complete(order)
      end
      flash[:completed] = true
      flash[:order_ids] = order_ids
      flash[:googleanalytics_ecs] = add_googleanalytics_ecs(@orders, @order_deliveries, @order_details)
      @carts.clear
    end
  end


=begin rdoc
  * INFO

      return:
        現在、カート内にある商品で購入時に加算されるポイントの合計値を返す。
        カートが空の場合はnilを返す。
=end
  def total_points
    @carts.inject(0) do | result, cart |
      cart.product or next
      point_rate_product = cart.product.point_granted_rate
      point_rate_shop = Shop.find(:first).point_granted_rate
      point_granted_rate = 0
      unless point_rate_product.blank?
        point_granted_rate = point_rate_product
      else 
        unless point_rate_shop.blank?
          point_granted_rate = point_rate_shop
        end
      end
      result + cart.price * point_granted_rate / 100 * cart.quantity
      end
  end

  def total_points_each_cart(carts)
    carts.inject(0) do | result, cart |
      cart.product or next
      point_rate_product = cart.product.point_granted_rate
      point_rate_shop = Shop.find(:first).point_granted_rate
      point_granted_rate = 0
      unless point_rate_product.blank?
        point_granted_rate = point_rate_product
      else 
        unless point_rate_shop.blank?
          point_granted_rate = point_rate_shop
        end
      end
      result + cart.price * point_granted_rate / 100 * cart.quantity
    end
  end

  # 購入時にログイン有無を確認してrenderするフィルタ
  def login_divaricate
    if @login_customer.nil?
      if params[:temporary_customer_flag] && params[:temporary_customer_flag] == "1"
        @not_login_customer = true
      end
    end
    unless @not_login_customer
      unless session[:customer_id]
        session[:return_to] = params if params
        redirect_to(:controller => 'accounts', :action => 'login')
      end  
    end
  end

  # @carts から条件に合うものを探す
  # ex) find_cart(:product_style_id => 1)
  def find_cart(conditions)
    @carts.detect do | cart |
      conditions.all? do | key, value |
        cart[key] == value
      end
    end
  end

  # POST 以外のアクセス禁止
  def force_post
    if request.method != :post
      render :template => 'cart/405', :status => :method_not_allowed
    end
  end

  # カートが空の時はアクセス不可
  def cart_check
    if @carts.blank?
      flash.now[:notice] = 'カートが空です'
      redirect_to(:action => 'show')
    end
  end

  def cart_errors(carts)
    errors = carts.enum_for(:each_with_index).reject do |c,_|
      c.valid?
    end.map do |c,i|
      c.errors.full_messages.map do |message|
        if c.product_style
          name = c.product_style.full_name
        else
          name = '%d 番目の商品' % (i+1)
        end
        '%s： %s' % [name, message]
      end
    end.flatten.uniq.join("\n")
  end

  def init_order_deliveries_for_complete
    @order_deliveries = Hash.new
    params[:order_deliveries].each do |key, order_delivery|
      @order_deliveries[key] = OrderDelivery.new(order_delivery)
      @order_deliveries[key].set_customer(@login_customer) if @login_customer
    end
    @order_details_map = Hash.new
    @order_deliveries.each do |key, order_delivery|
      cart = @carts_map[key.to_i]
      @order_details_map[key] = order_delivery.details_build_from_carts(cart)
    end
  end
  
  def init_order_deliveries
    @order_deliveries = Hash.new
    params[:order_deliveries].each do |key, order_delivery|
      @order_deliveries[key] = OrderDelivery.new(order_delivery)
      @order_deliveries[key].set_customer(@login_customer) if @login_customer
      @order_deliveries[key].payment_id = params[:order_delivery][:payment_id] unless params[:order_delivery].nil?
    end
    @order_details_map = Hash.new
    @order_deliveries.each do |key, order_delivery|
      cart = @carts_map[key.to_i]
      @order_details_map[key] = order_delivery.details_build_from_carts(cart)
    end
  end


  def init_order_delivery
    @order_delivery = OrderDelivery.new(params[:order_delivery])
    @order_delivery.set_customer(@login_customer) if @login_customer
    @order_details = @order_delivery.details_build_from_carts(@carts)
  end

  def process_campaign(cart, customer)
    cp = Campaign.find_by_id(cart.campaign_id)
    return if cp.product_id != cart.product_style.product_id
    return if cp.duplicated?(customer)
    cp.customers << customer
    cp.application_count ||= 0
    cp.application_count += 1
    cp.save!
  end

  # purchase だけで必要だが、他のアクションから render されることもあるのでいっそ全部で読み込む
  def find_payments
    @card_price or return false
    true
  end

  #戻るボタンから非会員入力画面へ戻る時
  def convert(params)
    order_delivery = OrderDelivery.new(params)
    #顧客情報
    @temporary_customer.family_name = order_delivery.family_name
    @temporary_customer.first_name = order_delivery.first_name
    @temporary_customer.family_name_kana = order_delivery.family_name_kana
    @temporary_customer.first_name_kana = order_delivery.first_name_kana
    @temporary_customer.tel01 = order_delivery.tel01
    @temporary_customer.tel02 = order_delivery.tel02
    @temporary_customer.tel03 = order_delivery.tel03
    @temporary_customer.fax01 = order_delivery.fax01
    @temporary_customer.fax02 = order_delivery.fax02
    @temporary_customer.fax03 = order_delivery.fax03
    @temporary_customer.zipcode01 = order_delivery.zipcode01
    @temporary_customer.zipcode02 =  order_delivery.zipcode02
    @temporary_customer.prefecture_id = order_delivery.prefecture_id
    @temporary_customer.address_city = order_delivery.address_city
    @temporary_customer.address_detail = order_delivery.address_detail
    @temporary_customer.email = order_delivery.email
    @temporary_customer.email_confirm = order_delivery.email
    @temporary_customer.sex = order_delivery.sex
    @temporary_customer.birthday = order_delivery.birthday
    @temporary_customer.occupation_id = order_delivery.occupation_id
    
    #お届け先情報
    @optional_address.family_name = order_delivery.deliv_family_name
    @optional_address.first_name = order_delivery.deliv_first_name
    @optional_address.family_name_kana = order_delivery.deliv_family_name_kana
    @optional_address.first_name_kana = order_delivery.deliv_first_name_kana
    @optional_address.tel01 = order_delivery.deliv_tel01
    @optional_address.tel02 = order_delivery.deliv_tel02
    @optional_address.tel03 = order_delivery.deliv_tel03
    @optional_address.zipcode01 = order_delivery.deliv_zipcode01
    @optional_address.zipcode02 =  order_delivery.deliv_zipcode02
    @optional_address.prefecture_id = order_delivery.deliv_pref_id
    @optional_address.address_city = order_delivery.deliv_address_city
    @optional_address.address_detail = order_delivery.deliv_address_detail
  end

  def add_googleanalytics_ecs(orders, deliveries, details_map)
    googleanalytics_ecs = Array.new
    orders.each do |key, order|
      delivery = deliveries[key]
      details = details_map[key]
      googleanalytics_ecs << add_googleanalytics_ec(order, delivery, details)
    end
    return googleanalytics_ecs
  end

  def add_googleanalytics_ec(order, delivery, details)
    ecommerce = GoogleAnalyticsEcommerce.new
    trans = GoogleAnalyticsTrans.new
    trans.order_id = order.code
    trans.affiliate = ""
    trans.city = delivery.address_city
    trans.country = "japan"
    trans.state = delivery.prefecture.name
    trans.shipping = delivery.deliv_fee.to_s
    trans.tax = "0"
    trans.total = delivery.total.to_s

    details.each do | detail |
      item = GoogleAnalyticsItem.new
      item.order_id = order.code
      item.category = detail.product_category.name
      item.product_name = detail.product_name
      item.price = detail.price.to_s
      item.quantity = detail.quantity.to_s
      item.sku = detail.product_style.manufacturer_id
      ecommerce.add_item(item)
    end

    ecommerce.trans = trans
    
    #flash[:googleanalytics_ec] = ecommerce
    return ecommerce
  end

  def select_delivery_trader_with_retailer_id(retailer_id)
    return DeliveryTrader.find(:all, :conditions => ["retailer_id = ?", retailer_id])
  end

  def select_delivery_time_with_delivery_trader_id(delivery_trader_id)
    delivery_times = DeliveryTime.find(:all, :conditions => ["delivery_trader_id = ? and name <> ''", delivery_trader_id], :order => 'position')
    options = [['指定なし', nil]]
    options.concat(delivery_times.map do |dt|
      [dt.name, dt.id]
    end)
    return options
  end
  
  def current_method_symbol
    caller.first.sub(/^.*`(.*)'$/, '\1').intern
  end

  def save_transaction_items_before_payment
    transaction_items = Hash.new
    transaction_items[:carts] = @carts
    transaction_items[:login_customer] = @login_customer
    transaction_items[:orders] = @orders
    transaction_items[:order_deliveries] = @order_deliveries
    transaction_items[:order_details] = @order_details
    transaction_items[:ids] = @ids
    transaction_items[:not_login_customer] = @not_login_customer
    session[:transaction_items] = transaction_items
  end

  def restore_transaction_items_after_payment
    transaction_items = session[:transaction_items]
    return false if transaction_items.nil?
    @carts = transaction_items[:carts]
    @login_customer = transaction_items[:login_customer]
    @orders = transaction_items[:orders]
    @order_deliveries = transaction_items[:order_deliveries]
    @order_details = transaction_items[:order_details]
    @ids = transaction_items[:ids]
    @not_login_customer = transaction_items[:not_login_customer]
    return true
  end
  
end
