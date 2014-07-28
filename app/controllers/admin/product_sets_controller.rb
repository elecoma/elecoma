# -*- coding: utf-8 -*-
# セット管理
class Admin::ProductSetsController < Admin::StockBaseController
  before_filter :admin_permission_check_product
  before_filter :load_sets, :except => [:edit, :index, :destroy]
  before_filter :get_product, :only => [:search, :new, :show, :edit, :confirm, :regist, :reset]
  after_filter :save_sets


SET_MAX_SIZE = 20

  def index
    @product_sets = ProductSet.find(:all, :order => :id)
  end

  def new
    if params[:id] && params[:id].to_i == 0
      @sets = []
      @product_set = ProductSet.new
      session[:product_set_id] = nil
    end
    @condition = StockSearchForm.new(params[:condition])
  end

  def edit
    @product_set = ProductSet.find(params[:id])
    @product = Product.find(@product_set.product_id)
    @product_statuses = ProductStatus.find(:all, :conditions=>["product_id=?", @product.id])
    get_product_status_by_params
    product_style_ids = @product_set.get_product_style_ids
    ps_counts = @product_set.get_ps_counts
    @sets = []
    product_style_ids.zip(ps_counts).each do |ps_id, ps_count|
      set = ProductSetStyle.new(:product_style => ProductStyle.find(ps_id),  :quantity => ps_count)
      @sets << set
    end
  end

  def show
    @product_statuses = ProductStatus.find(:all, :conditions=>["product_id=?", @product.id])
    get_product_status_by_params

    @product.sell_limit = 0 if @product.sell_limit.blank? && !@product.no_limit_flag
    @product.sale_end_at = 3.years.since
    @product.public_end_at = 3.years.since
  end

  def get_product
    if @product_set
      @product = Product.find(@product_set.product_id)
    else
      @product_set = ProductSet.new
      @product = Product.new
    end
    raise ActiveRecord::RecordNotFound if !@product.new_record? and @product.retailer_id != session[:admin_user].retailer_id
    @product.attributes = params[:product]
  end

  def get_product_status_by_params
    @product_statuses ||= []
    if !params[:product_status_ids].blank?
      params[:product_status_ids].each do | id |
        @product_statuses << ProductStatus.new(:product_id => @product.id, :status_id => id.to_i)
      end
    end
  end

  def confirm
    get_product_status_by_params

    @product.set_flag = true
    set_resource_old
    unless @product.valid?
      render :action => "show"
    end
  end

  def regist
    @product.sell_limit = nil if @product.no_limit_flag
    @product.save
    get_product_status_by_params
    @product.product_statuses = @product_statuses
    @product_statuses.each {|status| status.save}
    unless @product_set.new_record?
      ProductSet.find(@product_set.id).get_product_style_ids.each do |id|
        ps = ProductStyle.find(id)
        ids = ps.get_set_ids
        ids.delete(@product_set.id)
        ps.set_ids = ids.size > 0 ? ids.join(",") : nil
        ps.save
      end
    end
    @product_set.product_style_ids = @sets.map{|set| set.product_style_id}.join(",") 
    @product_set.ps_counts = @sets.map{|set| set.quantity}.join(",")
    @product_set.product_id = @product.id
    @product_set.save
    @order_unit = ProductOrderUnit.find_by_product_set_id(@product_set.id)
    @order_unit = ProductOrderUnit.new unless @order_unit
    @order_unit.set_flag = true
    @order_unit.sell_price = @product.price
    @order_unit.product_set_id = @product_set.id
    @order_unit.save
    @sets.each do |set|
      ps = ProductStyle.find(set.product_style_id)
      ids = ps.get_set_ids
      ids ||= []
      ids << @product_set.id
      ps.set_ids = ids.uniq.join(",")
      ps.save
    end
    @sets = []
  end

  def add_product
    set = @sets.find {|set| set.product_style_id == params[:id].to_i}
    if set.present?
      set.quantity += 1
    else
      if @sets.size >= SET_MAX_SIZE
        flash.now[:set_add_product] = '一つのセットに登録できる商品は' + "#{SET_MAX_SIZE}" + '種類までです。'
      else
        set = ProductSetStyle.new(:product_style => ProductStyle.find(params[:id]),  :quantity => 1)
        @sets ||= []
        @sets << set
        flash.now[:set_add_product] = "商品を追加しました"
      end
    end
    render :partial => "items"
  end

  def save_sets
    sets ||= @sets
    sets or return
    session[:sets] = sets
    session[:product_set_id] = @product_set.id if @product_set
  end

  def load_sets
    if @sets.nil? && session[:sets]
       @sets = session[:sets]
    end
    @sets ||= []
    @product_set = ProductSet.find(session[:product_set_id]) if session[:product_set_id]
  end

  def del
    # セッションから消す
    set = @sets.find {|set| set.product_style_id == params[:id].to_i}
    if set.present?
      @sets.reject!{|i|i==set}
    end
    render :partial => "items"
  end

  def modify
  end

  def inc
    set = @sets.find {|set| set.product_style_id == params[:id].to_i}
    if set.present?
      set.quantity += 1
    end
    render :partial => "items"
  end
  
  def dec
    set = @sets.find {|set| set.product_style_id == params[:id].to_i}
    if set.present?
      set.quantity -= 1 if set.quantity > 1
    end
    render :partial => "items"
  end

  def reset
    @sets = []
    redirect_to :action => :new
  end

  def destroy
    product_set = ProductSet.find(params[:id])
    ps_ids = product_set.get_product_style_ids
    ps_ids.each do |ps_id|
      ps = ProductStyle.find(ps_id)
      ids = ps.get_set_ids
      ids.delete(product_set.id)
      ps.set_ids = ids.join(",")
      ps.save
    end
    product = Product.find(product_set.product_id)
    product_order_unit = ProductOrderUnit.find_by_product_set_id(product_set.id)
    product_set.destroy
    product.destroy
    product_order_unit.destroy
    redirect_to :action => "index"
  end

  protected

  def set_resource_old
    [:small_resource, :medium_resource, :large_resource].each do | resource_name |
      resource_id = params["product_#{resource_name}_old_id".intern]
      if resource_id.to_s == 0.to_s
        if params[:product][resource_name]
          @product[resource_name] = params[:product][resource_name]
        else
          @product["#{resource_name}_id".intern] = nil
        end
      else
        @product["#{resource_name}_id".intern] = resource_id unless params[:product][resource_name]
      end
    end
  end

end
