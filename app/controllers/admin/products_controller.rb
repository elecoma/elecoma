# -*- coding: utf-8 -*-
require 'nkf'
class Admin::ProductsController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_product,
    :only => [:index, :show, :actual_count_list, :destroy]
  before_filter :admin_permission_check_product_entry,
    :only => [:new, :create, :update, :complete]
  before_filter :load_search_form
  after_filter :save_search_form

  def index
    get_search_form
  end

  def search
    get_search_form
    find_options = {
      :page => params[:page],
      :per_page => @search.per_page || 10,
      :conditions => flatten_conditions(@search_list),
      :include => Product::DEFAULT_INCLUDE,
      :order => "products.id"
    }
    @products = Product.paginate(find_options)
  end

  new_action.before do
    get_product

    get_product_status_by_params
    get_sub_product_by_params
    if params[:copy]
      @old_product = Product.find_by_id(params[:id].to_i)
      @old_product.id = nil
      params[:id] = nil
      @product = Product.new @old_product.attributes.reject{ |key, value| key.to_s == "id" }
    else
      @product = Product.new(params[:product])
      @product.sale_end_at = Date.today + 3 * 365 #30年後
      @product.public_end_at = Date.today + 3 * 365 #30年後
    end
  end

  def confirm
    get_product

    get_sub_product_by_params
    get_product_status_by_params
    set_resource_old

    unless @product.valid?
      render :action => (params[:id].blank? ? "new" : "edit")
    end
  end

  create.before do
    get_sub_product_by_params
    get_product_status_by_params
    @product.product_statuses = @product_statuses
    @product.sub_products = @sub_products
  end

  edit.before do
    get_product

    @product_statuses = ProductStatus.find(:all, :conditions=>["product_id=?", params[:id].to_i])
    get_sub_product_by_params
    get_product_status_by_params
  end

  update.before do
    get_sub_product_by_params
    get_product_status_by_params
    @product.product_statuses = @product_statuses
    @product.sub_products = @sub_products
  end


  #在庫切れ一覧
  def actual_count_index
    get_search_form(true)
  end

  def actual_count_search
    get_search_form(true)
    unless @search.no_product_style_count && @search.no_product_style_count.to_s == 1.to_s
      @search_list << ["product_styles.actual_count<=0 or product_styles.actual_count is null"]
    end
    find_options = {
      :page => params[:page],
      :per_page => @search.per_page || 10,
      :conditions => flatten_conditions(@search_list),
      :joins => "LEFT JOIN products ON products.id = product_styles.product_id ",
      :order => "id"
    }
    @products = ProductStyle.paginate(find_options)
  end

  def permit_setting
    params[:product_permit_ids] and params[:product_permit_ids].each do | id |
      product = Product.find_by_id id
      permit = params[:product_permit] && params[:product_permit][id]
      product.permit = permit == "true" ? true : false
      product.save_without_validation
    end
    redirect_to :action => "search", :search => params[:search], :page => params[:page]
  end

  def csv_download
    @search_list = []
    get_search_form
    csv_data, filename = Product.csv(@search_list)
    send_data(csv_data, :type => "application/octet-stream; name=#{filename}; charset=shift_jis; header=present",:disposition => 'attachment', :filename => filename)
  end

  def csv_upload
    line = 0
    file = params[:upload_file]

    begin
      if CSVUtil.valid_data_from_file?(file)
        line, result = Product.add_by_csv(file, session[:admin_user].retailer_id)
        unless result
          line = line + 1
          flash[:product_csv_upload_e] = "#{line}行目のデータが不正です。最初からやり直して下さい。"
          redirect_to :action => "index"
          return
        end
        flash[:product_csv_upload] = "#{line}件のデータが登録されました"
        redirect_to :action => "index"
      else
        flash[:product_csv_upload_e] = "CSVファイルが空か、指定されたファイルが存在しません"
        redirect_to :action => "index"
      end
    rescue => e
      logger.error("product_controller#csv_upload catch error: " + e.to_s)
      flash[:product_csv_upload_e] = "エラーが発生しました。最初からやり直して下さい。"
      redirect_to :action => "index"
    end
  end

  def actual_count_csv_download
    @search_list = []
    get_search_form
    csv_data, filename = Product.actual_count_list_csv(@search_list)
    send_data(csv_data, :type => "application/octet-stream; name=#{filename}; charset=shift_jis; header=present",:disposition => 'attachment', :filename => filename)
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

  def get_sub_product_by_params
    @sub_products = []
    @sub_products = SubProduct.find(:all, :conditions => ["product_id = ?",@product.id], :order => "no") unless @product.id.blank?
    unless @sub_products.size == 5
      5.times do |idx|
        @sub_products << SubProduct.new(:no => idx )
      end
    end
    if params[:sub_product]
      params[:sub_product].each do |idx,  sub_products |
        sub_product = @sub_products[idx.to_i]
        sub_products.delete(:medium_resource_id) if sub_products && !sub_products[:medium_resource].blank?
        sub_products.delete(:large_resource_id) if sub_products && !sub_products[:large_resource].blank?
        sub_product.attributes = sub_products
        @product.sub_products << sub_product
        @sub_products[idx.to_i] =  sub_product
      end
    end
  end

  def get_product_status_by_params
    @product_statuses ||= []
    if !params[:product_status_ids].blank?
      params[:product_status_ids].each do | id |
        @product_statuses << ProductStatus.new(:product_id => @product.id, :status_id => id.to_i)
      end
    end
  end

  private

  def get_product
    @product = Product.find_by_id(params[:id].to_i) || Product.new
    raise ActiveRecord::RecordNotFound if !@product.new_record? and @product.retailer_id != session[:admin_user].retailer_id
    @product.attributes = params[:product]
  end

  def get_search_form(actual_flg=false)
    addparam = {'retailer_id' => session[:admin_user].retailer_id}
    params[:search].merge! addparam unless params[:search].nil?
    @search = SearchForm.new(params[:search])
    @search, @search_list = Product.get_conditions(@search, params, actual_flg)
  end

  def save_search_form
    if @search
      flash.now[:order_search] = @search.attributes.reject{|_,v|v.blank?}
    end
  end

  def load_search_form
    unless @search
      @search = SearchForm.new(flash.now[:order_search])
    end
  end
end
