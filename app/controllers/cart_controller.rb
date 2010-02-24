# -*- coding: utf-8 -*-
require 'timeout'
require 'open-uri'
class CartController < BaseController
  before_filter :cart_check, :only => [:temporary_shipping,:shipping, :purchase,:purchase2, :confirm, :complete]
  before_filter :login_divaricate ,:only =>[:purchase,:purchase2,:confirm, :complete]
  before_filter :login_check, :only => [:shipping]
  before_filter :force_post, :only => [:purchase,:purchase2,:confirm, :complete]
  after_filter :save_carts
  before_filter :verify_session_token, :except => :select_delivery_time
  
  CARTS_MAX_SIZE = 20
  DENA_AFFILIATE_URL = 'http://smaf.jp/req.cgi'

  # カートの中を見る。Loginの可否、カート内容の有無で動的に変動。カート操作全般はここから行う。
  def show
    unless @carts.all?(&:valid?)
      flash.now[:error] = cart_errors(@carts)
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
        convert(params[:order_delivery])
     end
  end
  
  # Order を作る
  def purchase
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
        convert(params[:order_delivery])
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

    # 確認ページから帰ってきた時は params[:order_delivery] があるはず
    @order_delivery = OrderDelivery.new(params[:order_delivery])
    #確認ページから帰ってきた時、ポイント使用有無ラジオボタン維持
    if @login_customer && params[:back] == "1"
      if !@order_delivery.use_point.blank? && @order_delivery.use_point > 0
        @point_check = true
      else
        @point_check = false
        @order_delivery.use_point = nil
      end        
    end
    # 「戻る」以外の時代入
    @order_delivery.address_select ||= params[:address_select].to_i
    if @order_delivery.deliv_zipcode01.blank?
      @order_delivery.set_delivery_address(@delivery_address)
    end

    if params[:order_delivery]
      @order_delivery.target_columns = params[:order_delivery].keys.map(&:to_s)
    end
    #@payments = @order_delivery.payment_candidates(@cart_price)
    #配送時間取得・表示のAJAXははお支払方法押下時のみ行い、戻るボタンで戻る時、配送時間表示がおかしくないため、
    #支払方法を強制にクリア。モバイルはAJAXを使っていないので、そのまま
    @order_delivery.payment = nil unless request.mobile?

    # 非会員フラグ追加
    # 非会員購入時の顧客情報セット
    if @not_login_customer
      @order_delivery.set_customer(@temporary_customer)
    end
    render :action => 'purchase'
  end
  
  #モバイルお届け時間選択
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
    init_order_delivery
    unless @order_delivery.valid?
      @order_delivery.payment = nil unless request.mobile?
      if params[:point_check] == "true"
        @point_check = true
      end
      render :action => 'purchase'
      return
    end
    
    # ポイント
    if @login_customer
      use_point = 0
      if params[:point_check] == "true"
        @point_check = true
        use_point = @order_delivery.use_point.to_i
        if use_point == 0
           flash.now[:error] = '使用ポイントをご入力ください。 '
           @order_delivery.payment = nil unless request.mobile?
           render :action => 'purchase'
           return
        end
        # ポイントの使いすぎをチェック
        if use_point > @cart_price
          flash.now[:error] = 'ご利用ポイントがご購入金額を超えています。'
          @order_delivery.payment = nil unless request.mobile?
          render :action => 'purchase'
          return
        end
        if use_point > @login_customer.point.to_i
          flash.now[:error] = 'ご利用ポイントが所持ポイントを超えています。'
          @order_delivery.payment = nil unless request.mobile?
          render :action => 'purchase'
          return
        end        
      else
        @point_check = false
        @order_delivery.attributes = {:use_point => 0}
      end
      
      @cart_point = total_points
      @point_after_operation = @login_customer.point.to_i - use_point + total_points
      #add_point追加
      @order_delivery.attributes = {:add_point => @cart_point}
    end
    #ポイントのことで再計算はここにする
    @order_delivery.calculate_charge!
    @order_delivery.calculate_total!
    
    @next = :complete
    render :action => 'confirm'
  end

  #完了画面
  def complete
    unless @carts.all?(&:valid?)
      redirect_to :action => :show
      return
    end
    # 受注を作って受注可能数を減らす
          # 　非会員購入追加
    if @not_login_customer
      @order = Order.new
    elsif @login_customer
      @login_customer.point = params[:point_after_operation]
      @order = @login_customer.orders.build
    end
    @order.received_at = DateTime.now
    @order_delivery = @order.order_deliveries.build(params[:order_delivery])
    
    # 　非会員購入追加
    if @login_customer
      @order_delivery.set_customer(@login_customer)  
    end
  
    ## ステータス
    @order_delivery.status = OrderDelivery::JUTYUU
    # 受注発注商品が一つでもあるか
    product_styles = @carts.map(&:product_style)
    #販売可能数で判断
    if product_styles.any?{|ps| ps.orderable_count.to_i == 0}
      # 販売開始日が未来の物が一つでもあれば予約
      products = product_styles.map(&:product)
      today = Date.today
      if products.any?{|p| p.sale_start_at && p.sale_start_at > today}
        @order_delivery.status = OrderDelivery::YOYAKU_UKETSUKE
      else
        @order_delivery.status = OrderDelivery::JUTYUU_TOIAWASE
      end
    end
    @carts.each do |cart|
      cart.product_style.order(cart.quantity)
    end
    @order_details = @order_delivery.details_build_from_carts(@carts)
    @order_delivery.calculate_charge!
    @order_delivery.calculate_total!

    unless @order_delivery.valid? and @order_details.all?(&:valid?)
      render :action => 'purchase'
      return
    end
    begin
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
        @order.save!
        flash[:completed] = true
        flash[:order_id] = @order.id
        # メールを送る
        Notifier::deliver_buying_complete(@order)
        flash[:googleanalytics_ec] = add_googleanalytics_ec(@order, @order_delivery, @order_details)
        @carts.clear
      end
    rescue => e
      flash.now[:error] = '失敗しました'
      logger.error(e.message)
      e.backtrace.each{|s|logger.error(s)}
      redirect_to :action => 'show'
      return
    end
    redirect_to :action => :finish, :ids => @order_details.map{|o_d| o_d.product_style.product_id}
  end

  def finish
    unless flash[:completed]
      render :template => 'cart/405', :status => :method_not_allowed
      return
    end
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
        ProductStyle.find_by_id(params[:product_style_id])
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
    
    flash[:googleanalytics_ec] = ecommerce
  end

end
