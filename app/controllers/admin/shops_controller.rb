# -*- coding: utf-8 -*-
class Admin::ShopsController < Admin::BaseController
  before_filter :admin_permission_check_shop, :only => [:index, :update]
  before_filter :admin_permission_check_commerce_low,
    :only => [:tradelaw_index, :tradelaw_update]
  before_filter :admin_permission_check_delivery,
    :only => [:delivery_index, :delivery_new, :delivery_edit, :delivery_create, :delivery_update, :destroy, :sort]
  before_filter :admin_permission_check_payment,
    :only => [:payment_index, :payment_new, :payment_edit, :payment_create, :payment_update, :destroy, :sort]
  before_filter :admin_permission_check_mail, :only => [:mail_index, :mail_update]
  before_filter :admin_permission_check_seo, :only => [:seo_index, :seo_update]
  before_filter :admin_permission_check_member_rule,
    :only => [:kiyaku_index, :kiyaku_create, :kiyaku_update, :destroy, :sort]
  before_filter :admin_permission_check_privacy, :only => [:privacy, :privacy_update]
  before_filter :admin_permission_check_setting, :only => [:settings, :settings_update]
  before_filter :master_shop_check, :except => [:delivery_index, :delivery_new, :delivery_edit, :delivery_create, :delivery_update, :destroy, :sort, :get_address]

  def index
    @shop = Shop.find(:first)
    if @shop
      @id=@shop.id
    end
  end


  def update
    @shop = Shop.find(:first) || Shop.new
    @shop.attributes = params[:shop]
    @system = System.find(:first) || System.new
    @system.attributes = params[:system]

    unless @shop.valid? && @system.valid?
      render :action => "index"
      return
    end

    if @system.save && @shop.save
      flash[:shop_update] = "データを保存しました"
    else
      flash[:shop_update_e] = "データの保存に失敗しました"
    end

    redirect_to :action => "index"
  end


  def delivery_index
    @model_name = "delivery_trader"
    @model = DeliveryTrader

    @delivery_traders = @model.paginate(:conditions => ["retailer_id = ? ", session[:admin_user].retailer_id],
                               :page => params[:page],
                               :per_page => params[:per_page] || 10,
                               :order => :position)
  end

  def delivery_new
    @delivery_trader = DeliveryTrader.new
    @delivery_time = []
    @delivery_fee = []
    (DeliveryFee::MAX_SIZE-1).times do |index|
      df = DeliveryFee.new(:prefecture_id => index+1)
      @delivery_fee << df
    end
    @delivery_fee << DeliveryFee.new
  end

  def delivery_edit
    @delivery_trader = DeliveryTrader.find(params[:id])
    @delivery_time = @delivery_trader.delivery_times
    @delivery_fee = @delivery_trader.delivery_fees
  end


  def delivery_create
    @delivery_time=[]
    @delivery_fee=[]

    DeliveryTime::MAX_SIZE.times do |index|
      dt =  DeliveryTime.new(params[:delivery_time]["#{index}"])
      dt.position=index+1
      @delivery_time << dt
    end

    DeliveryFee::MAX_SIZE.times do |index|
      df =  DeliveryFee.new(params[:delivery_fee]["#{index}"])
      df.prefecture_id=index+1 if index<47
      @delivery_fee << df
    end

    @delivery_trader = DeliveryTrader.new params[:delivery_trader]

    DeliveryTrader.transaction do
      @delivery_trader.position=DeliveryTrader.count+1

      err_flg=false
      err_flg = true unless @delivery_trader.valid?
      @delivery_time.each {|dt| err_flg = true unless dt.valid?  }
      @delivery_fee.each {|df| err_flg = true unless df.valid?  }

      if err_flg
        flash.now[:error] = "保存に失敗しました"
        render :action => "delivery_new"
        return
      end

      if @delivery_trader.delivery_times << @delivery_time && @delivery_trader.delivery_fees << @delivery_fee&& @delivery_trader.save
        flash.now[:notice] = "データを保存しました"
        redirect_to :action => "delivery_index"
      else
        flash.now[:error] = "保存に失敗しました"
        render :action => "delivery_new"
      end
    end
  end

  def delivery_update
    @delivery_trader = DeliveryTrader.find(params[:id])
    @delivery_time = @delivery_trader.delivery_times
    @delivery_fee =@delivery_trader.delivery_fees
    DeliveryTime::MAX_SIZE.times do |index|
      @delivery_time[index].attributes = params[:delivery_time]["#{index}"]
    end

    DeliveryFee::MAX_SIZE.times do |index|
      @delivery_fee[index].attributes = params[:delivery_fee]["#{index}"]
    end
    @delivery_trader.attributes = params[:delivery_trader]
    err_flg=false
    err_flg = true unless @delivery_trader.valid?
    @delivery_time.each {|dt| err_flg = true unless dt.valid?  }
    @delivery_fee.each {|df| err_flg = true unless df.valid?  }

    if err_flg
      flash.now[:error] = "保存に失敗しました"
      render :action => "delivery_edit"
      return
    end
    DeliveryTrader.transaction do
      if @delivery_trader.delivery_times << @delivery_time && @delivery_trader.delivery_fees << @delivery_fee&& @delivery_trader.save
        flash.now[:notice] = "データを保存しました"
        redirect_to :action => "delivery_index",:id=>params[:id]
      else
        flash.now[:error] = "保存に失敗しました"
        render :action => "delivery_edit"
      end
    end
  end

  def point_index
    @shop = Shop.find(:first)
    if @shop
      @id=@shop.id
    end
  end

  def point_update
    unless params[:id].blank?
      @shop = Shop.find(:first)
      @shop.attributes = {:point_granted_rate => params[:shop][:point_granted_rate],:point_at_admission =>params[:shop][:point_at_admission]}
    else
      flash.now[:error] = "保存に失敗しました。"
      render :action => "point_index"
      return
    end
    unless @shop.valid?
      flash.now[:error] = "保存に失敗しました"
      @id = params[:id]
      render :action => "point_index"
      return
    end
    if @shop.save
      flash.now[:notice] = "データを保存しました"
    else
      flash.now[:error] = "データの保存に失敗しました"
    end
    redirect_to :action => "point_index"
  end

  def payment_index
    @model_name = "payment"
    @model = Payment

    @payments = Payment.find(:all, :order => "position")
  end

  def payment_new
    @payment = Payment.new
  end

  def payment_edit
    @payment = Payment.find(params[:id])
    if !@payment.id
      flash.now[:error] = "該当するデータがありませんでした"
      redirect_to :action=>:payment_new
    end
  end

  def payment_create
    @payment = Payment.new params[:payment]
    Payment.transaction do
      unless @payment.valid?
        flash.now[:error] = "保存に失敗しました"
        render :action => "payment_new"
        return
      end
      if @payment && @payment.save
        flash.now[:notice] = "データを保存しました"
      else
        flash.now[:error] = "保存に失敗しました"
      end
        redirect_to :action => "payment_index"
    end
  end

  def payment_update
    @payment = Payment.find(params[:id])
    @payment.attributes = params[:payment]
    set_payment_resource_old
    unless @payment.valid?
      flash.now[:error] = "保存に失敗しました"
      render :action => "payment_edit"
      return
    end

    Payment.transaction do
      if @payment && @payment.save
        flash.now[:notice] = "データを保存しました"
      else
        flash.now[:error] = "保存に失敗しました"
      end
    end
        redirect_to :action => "payment_index"
  end

  def tradelaw_index
    @law = Law.find(:first)
    if @law
      @status = "update"
      @id=@law.id
    else
      @law = Law.new
      @status = "create"
    end
  end

  def tradelaw_update
    if !params[:id].blank?
      @law = Law.find(:first)
      @law.attributes = params[:law]
    else
      @law = Law.new params[:law]
    end

    unless @law.valid?
      flash.now[:error] = "保存に失敗しました"
      render :action => "tradelaw_index"
      return
    end

    if @law && @law.save
      flash.now[:notice] = "データを保存しました"
    else
      flash.now[:error] = "保存に失敗しました"
    end
    redirect_to :action => "tradelaw_index"
  end

  def mail_index
    @mail = MailTemplate.new
  end

  def mail_search
    @id = params[:id]
    unless @id.blank?
      @mail = MailTemplate.find(@id)
    else
      @mail = MailTemplate.new
    end
    render :partial => "mail_form"
  end

  def mail_update
    id = params[:mail][:id]
    unless id.blank?
      @mail = MailTemplate.find(id)
      @mail.attributes = params[:mail]
    else
      flash[:mail_e] = "テンプレートを選択してください"
      redirect_to :action => "mail_index"
      return
    end

    unless @mail.valid?
      flash[:mail_e] = "保存に失敗しました"
      render :action => "mail_index"
      return
    end
    if @mail.save
      flash[:mail] = @mail.name + "を保存しました"
    else
      flash[:mail_e] = "保存に失敗しました"
    end
    redirect_to :action => "mail_index"
  end

  def seo_index
    @seos = Seo.find(:all, :order=>"page_type")
  end

  def seo_update
    @seos = Seo.find(:all, :order=>"page_type")
    if !params[:seo][:page_type].blank?
      @seo = Seo.find_by_page_type(params[:seo][:page_type])
      @seo.attributes = params[:seo]
    else
      redirect_to :action => :seo_index
      return
    end

    unless @seo.valid?
      flash.now[:error] = "保存に失敗しました"
      render :action => :seo_index
      return
    end

    if @seo && @seo.save
      flash.now[:notice] = "データを保存しました"
    else
      flash.now[:error] = "の保存に失敗しました"
    end
    redirect_to :action => :seo_index
  end

  def kiyaku_index
    kiyaku_list
    if params[:id]
      @kiyaku = Kiyaku.find_by_id(params[:id])
    else
      @kiyaku = Kiyaku.new
    end
  end

  def kiyaku_create
    @kiyaku = Kiyaku.new params[:kiyaku]
    Kiyaku.transaction do
      unless @kiyaku.valid?
        kiyaku_list
        flash.now[:error] = "保存に失敗しました"
        render :action => :kiyaku_index
        return
      end

      if @kiyaku && @kiyaku.save
        flash.now[:notice] = "データを保存しました"
      else
        flash.now[:error] = "保存に失敗しました"
      end
      redirect_to :action => "kiyaku_index"
    end
  end

  def kiyaku_update
    @kiyaku = Kiyaku.find(params[:kiyaku][:id])
    @kiyaku.attributes = params[:kiyaku]
    unless @kiyaku.valid?
      kiyaku_list
      flash.now[:error] = "保存に失敗しました"
      render :action => "kiyaku_index"
      return
    end

    Kiyaku.transaction do
      if @kiyaku && @kiyaku.save
        flash.now[:notice] = "データを保存しました"
      else
        flash.now[:error] = "保存に失敗しました"
      end
    end
    redirect_to :action => "kiyaku_index"
  end

  def privacy
    #１件のみ返す
    @privacy = Privacy.first
  end

  def privacy_update
    if request.method != :post
      redirect_to :action=>:privacy
      return
    end
    
    if @privacy = Privacy.first #１件のみ返す
      @privacy.attributes = params[:privacy]
    else
      @privacy = Privacy.new params[:privacy]
    end

    unless @privacy.valid?
      render :action => "privacy"
      return
    end

    if @privacy.save
      flash[:shop_privacy] = "データを保存しました"
    else
      flash[:shop_privacy_e] = "データの保存に失敗しました"
    end
    redirect_to :action=>:privacy
  end

  def privacy_preview
    @preview_id = params[:preview_id]
    @privacy = Privacy.new params[:privacy]
    if @preview_id == "1" || @preview_id == "3"
      render :template => '/admin/shops/privacy_preview_mobile', :layout => '/admin/preview_base_mobile'
    else
      render :template => '/admin/shops/privacy_preview', :layout => '/admin/preview_base'
    end    
  end
  
  def up
    super
    redirect_to :action => params[:return_act]
  end

  def down
    super
    redirect_to :action => params[:return_act]
  end

  def destroy
    get_model
    if @model.find(:first, :conditions => ["id = ? ", params[:id]] ) && @model.destroy(params[:id])
      flash.now[:notice] = "削除しました"
    else
      flash.now[:error] = "削除に失敗しました"
    end

    redirect_to :action => params[:return_act]
  end
  #使用機能一覧
  def settings
    #初期化
    @system ||= System.new
    @system.supplier_use_flag ||= false
  end
  #使用機能設定
  def settings_update
    type = params[:set_id]
    case type.to_i
      #set_id_id = 1の場合、仕入先使用か使用しないかの設定
    when 1
      supplier_update
    when 2
      googleanalytics_update
    when 3
      ssl_update
    else
      #将来何か追加したい場合、ここで追加してください
      render :action => "settings"
      return
    end
  end

  private

  def set_payment_resource_old
    if resource_id = params["payment_resource_old_id".intern]
      if resource_id.to_s == 0.to_s
        @payment["resource_id".intern] = nil
      elsif !resource_id.blank? && params[:payment]["resource"]
        return
      else
        @payment["resource_id".intern] = resource_id unless @payment["resource_id".intern]
      end
    end
  end

  def kiyaku_list
    @model_name = "kiyaku"
    @model = Kiyaku
    if params[:id]
      @status ="kiyaku_update"
    else
      @status="kiyaku_create"
    end

    @kiyakus = Kiyaku.find(:all, :order=>"position")
  end

  #SSLを使用するかどうか設定
  def ssl_update
    @system ||= System.new
    @system.attributes = params[:system]
    if @system.save
      if @system.use_ssl
        flash[:ssl_update] = "SSLを有効にしました"
        redirect_to :controller => "shops",:action => "settings"
        return
      else
        flash[:ssl_update] = "SSLを無効にしました"
        redirect_to :controller => "shops",:action => "settings"
        return
      end
    else
      flash.now[:error] = "設定に失敗しました"
      render :action => "settings"
      return
    end
  end

  #仕入先を使用するかどうか設定
  def supplier_update
    @system ||= System.new
    @system.attributes =  params[:system]
    if @system.save
      if @system.supplier_use_flag
        #使用する->使用しない変更する時、既存の仕入先をそのまま
        #supplier_use_flagの変更のみ        
        redirect_to :controller => "suppliers",:action => ""
        return
      else
        flash[:system_update] = "仕入先を使用しないように設定しました"
        redirect_to :controller => "shops",:action => "settings"
        return
      end
    else
      flash.now[:error] = "設定に失敗しました"
      render :action => "settings"
      return
    end     
  end

  #GoogleAnalyticsを使用するかどうか設定
  def googleanalytics_update
    @system.attributes =  params[:system]
    if @system.googleanalytics_use_flag
        @system.tracking_code = @system.tracking_code.gsub(/UA-XXXXX-X/, @system.googleanalytics_account_num)
    end    
    if @system.save
      if @system.googleanalytics_use_flag
        flash.now[:notice_google] = "GoogleAnalyticsを使用するように設定しました"
        render :action => "settings"
      else
        flash.now[:notice_google] = "GoogleAnalyticsを使用しないように設定しました"
        render :action => "settings"
      end
    else
      flash.now[:error_google] = "設定に失敗しました"
      render :action => "settings"
    end
  end

end
