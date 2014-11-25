# -*- coding: utf-8 -*-
# 返品処理コントローラ

require 'csv'

class Admin::ReturnItemsController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_return_item
  caches_page :csv

  def index
  end

  new_action.before do
    @pou = ProductOrderUnit.find_by_id(params[:id].to_i)
  end

  new_action.wants.html do
    if @pou.nil?
      redirect_to :action => :index
    elsif @pou.ps.product.retailer_id != session[:admin_user].retailer_id
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  edit.before do
    ri = ReturnItem.find_by_id(params[:id].to_i)
    @pou = ProductOrderUnit.find_by_id(ri.product_order_unit_id) unless ri.nil?
  end

  edit.wants.html do
    if @pou.nil?
      redirect_to :action => :history
    elsif @pou.ps.product.retailer_id != session[:admin_user].retailer_id
      redirect_to :action => :history
    else
      render :action => :edit
    end
  end

  [create, update].each do |action|
    action.before do
      @pou = ProductOrderUnit.find_by_id(params[:return_item][:product_order_unit_id].to_i)
      @return_item.admin_user_id = session[:admin_user].id
      raise ActiveRecord::RecordNotFound if @pou.ps.product.retailer_id != session[:admin_user].retailer_id
    end
  end  
  
  create.wants.html do
    flash[:return_item_update] = "データを保存しました。"
    redirect_to :action => "index"
  end

  update.wants.html do
    flash[:return_item_update] = "データを保存しました。"
    redirect_to :action => "history"
  end

  destroy.wants.html do
    flash[:return_item_update] = "データを削除しました。"
    redirect_to :action => "history"
  end

  def history
  end

  def history_search
    get_return_items
  end

  def search
    add_retailer_condition
    @condition = ReturnItemSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => :index
      return
    end
    @condition, @search_list = Product.get_conditions(@condition, params, true)
    @products = Product.find(:all,:conditions => flatten_conditions(@search_list),:joins => "LEFT JOIN product_styles ON product_styles.product_id = products.id ")
    @pous = []
    @products.each do |product|
      if product.is_set?
        @pous << ProductOrderUnit.find(:first, :conditions => {:product_set_id => product.product_set.id})
      else
        @product_styles = product.product_styles
        @product_styles.each do |ps|
          @pous << ProductOrderUnit.find(:first, :conditions => {:product_style_id => ps.id})
        end
      end
    end
    order_options = {
      :page => params[:page],
      :per_page => @condition.per_page || 10,
      :order => "product_order_units.id"
    }
    @pous = @pous.paginate(order_options)
  end

  def csv_index
    pairs = CSVUtil.make_csv_index_pairs(params[:controller], page_cache_directory, page_cache_extension)
    unless pairs
      @dates = []
      @urls = []
      return
    end
    @dates = pairs.map do |_, time|
      time
    end
    @urls = pairs.map do |id, _|
      url_for(:action => :csv, :id => id,:format => "csv")
    end
  end
  
  def new_csv
    redirect_to(url_for_date(DateTime.now))
  end

  def csv
    # params[:id] はページキャッシュのキーにするだけで抽出条件にはしない
    if params[:id].blank?
      render :status => :not_found
    end
    @return_items = ReturnItem.all.select {|ri| ri.path_product.product.retailer.id == session[:admin_user].retailer_id}
    

    rows = @return_items.map do |ri|
      a = []
      a << ri.path_product.product.id
      ri.is_set? ? a << "" : a << ri.path_product.code
      a << ri.path_product.product.name
      ri.is_set? ? a << "" : a << ri.path_product.style_name
      ri.is_set? ? a << "" : a << ri.path_product.manufacturer_id
      a << ri.returned_count
      a << ri.returned_at
      a
    end
    name = params[:id]
    filename = '%s.csv' % name
    header = %w( 商品ID 商品コード 商品名 規格名称 商品型番 返品数 返品日時 )
    csv_text = CSVUtil.make_csv_string(rows, header)
    send_csv(csv_text, filename)
  end
    

  private
  def get_return_items
    add_retailer_condition
    @condition = ReturnItemSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => :index
      return
    end
    @search_list = ReturnItemSearchForm.get_conditions(@condition)
    @search_list << [ 'product_order_units.deleted_at IS NULL' ]
    find_options = {
      :page => params[:page], 
      :per_page => @condition.per_page || 10,
      :conditions => flatten_conditions(@search_list),
      :joins=> :product_order_unit,
      :include => [:product],
      :order => "return_items.id"
    }
    @return_items = ReturnItem.paginate(find_options)
  end
  
  def url_for_date(date)
    url_for(:action => :csv, :id => date.strftime('%Y%m%d_%H%M%S'),:format => "csv")
  end  

  def add_retailer_condition
    addparam = {'retailer_id' => session[:admin_user].retailer_id}
    params[:condition].merge! addparam unless params[:condition].nil?
  end

  def get_csv_condition
    condition = []
=begin
    condition << ["products.retailer_id = ?", session[:admin_user].retailer_id]
    return condition, "LEFT JOIN product_styles ON product_styles.id = return_items.product_style_id " + "LEFT JOIN products ON products.id = product_styles.product_id "
=end
  end

end
