# -*- coding: utf-8 -*-
class Admin::PluginsController < Admin::BaseController
  include Admin::PluginsControllerExtend

  before_filter :admin_permission_check_plugins
  before_filter :master_shop_check

  def index
    @payment_plugins = PaymentPlugin.find(:all, :order => :id)
  end

  def new_payment_plugin
    #render :layout => false
    @payment_plugin = PaymentPlugin.new
  end

  def edit_payment_plugin
    unless params[:id].blank?
      @payment_plugin = PaymentPlugin.find_by_id(params[:id].to_i)
    end
    unless params[:payment_plugin].blank?
      @payment_plugin = PaymentPlugin.find_by_id(params[:payment_plugin][:id].to_i)
      @payment_plugin.attributes = params[:payment_plugin]
      params[:id] = params[:payment_plugin][:id].to_i
    end
    redirect_to :action => "index" if @payment_plugin.nil?
  end

  def confirm_payment_plugin
    @payment_plugin = PaymentPlugin.find_by_id(params[:id].to_i) || PaymentPlugin.new
    @payment_plugin.attributes = params[:payment_plugin]
    unless @payment_plugin.valid?
      if params[:id].blank? and params[:payment_plugin][:id].blank?
        render :action => "new_payment_plugin"
      else
        render :action => "edit_payment_plugin"
      end
      return
    end
  end

  def create_payment_plugin
    save_payment_plugin(:create)
  end
  
  def update_payment_plugin
    save_payment_plugin(:update)
  end

  def edit_payment_plugin_config
    @payment_plugin = PaymentPlugin.find_by_id(params[:id].to_i)
    if @payment_plugin.nil?
      redirect_to(:action => :index)
      return
    end
    @payment_plugin_instance = @payment_plugin.get_plugin_instance
    if @payment_plugin_instance.nil?
      redirect_to(:action => :index)
      return
    end
    unless @payment_plugin_instance.has_config?
      redirect_to(:action => :index)
      return
    end
    next_action = @payment_plugin_instance.config
    redirect_to(:action => next_action)
  end

  def payment_plugin_data_management
    unless get_plugin_instance(params[:id].to_i)
      flash[:notice] = "このプラグインのインスタンスが取得できません。無効になっているか確認してください。"
      redirect_to(:action => :index)
      return
    end
    unless @payment_plugin_instance.has_data_management?
      flash[:notice] = "このプラグインにデータ管理はありません"
      redirect_to(:action => :index)
      return
    end
    next_action = @payment_plugin_instance.data_management
    redirect_to(:action => next_action, :id => 1)
  end    

  def payment_plugin_config
    unless get_plugin_instance(params[:id].to_i, true)
      flash.now[:notice] = "このプラグインのインスタンスが取得できません。無効になっているか確認してください。"
      redirect_to(:action => :index)
      return
    end
    unless @payment_plugin_instance.has_config?
      flash.now[:notice] = "このプラグインに設定ページはありません"
      redirect_to(:action => :index)
      return
    end
    next_action = @payment_plugin_instance.config
    redirect_to(:action => next_action, :id => 1)
  end

  def payment_plugin_info
    unless get_plugin_instance(params[:id].to_i, true)
      flash.now[:notice] = "このプラグインのインスタンスが取得できません。クラスが正しく設定されているか確認してください。"
      redirect_to(:action => :index)
      return
    end
    unless @payment_plugin_instance.has_info?
      flash.now[:notice] = "このプラグインに詳細ページはありません"
      redirect_to(:action => :index)
      return
    end
    next_action = @payment_plugin_instance.info
    redirect_to(:action => next_action, :id => 1)
  end
  private

  def get_plugin_instance(id, disable_flg = false)
    @payment_plugin = PaymentPlugin.find_by_id(id)
    if @payment_plugin.nil?
      return false
    end
    @payment_plugin_instance = @payment_plugin.get_plugin_instance(disable_flg)
    if @payment_plugin_instance.nil?
      return false
    end
    return true
  end
  
  def save_payment_plugin(type)
    if type == :create
      back_to = :new_payment_plugin
      @payment_plugin = PaymentPlugin.new(params[:payment_plugin])
    elsif type == :update
      back_to = :edit_payment_plugin
      @payment_plugin = PaymentPlugin.find_by_id(params[:payment_plugin][:id].to_i)
      @payment_plugin.attributes = params[:payment_plugin]
    else
      raise "不正な遷移"
    end
    if @payment_plugin.save
      flash.now[:notice] = "データを保存しました"
      redirect_to :action => :index
    else
      flash.now[:notice] = "エラーが発生しました"
      render :action => back_to
      return
    end
  end

end
