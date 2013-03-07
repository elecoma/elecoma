# -*- coding: utf-8 -*-
require 'csv'
require 'thinreports'
include ActionView::Helpers::NumberHelper

class Admin::OrdersController < Admin::BaseController
  before_filter :admin_permission_check_receive
  before_filter :load_search_form
  after_filter :save_search_form

  def index
    get_search_form
  end

  def search
    list
  end

  def edit
    order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    raise ActiveRecord::RecordNotFound if order_delivery.nil? || order_delivery.order.retailer_id != session[:admin_user].retailer_id
    if params[:recalculate]
      recalculate
      return
    end
    if request.method == :put
      update
      return
    end
    @order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    @order_delivery_ticket = @order_delivery.ticket_code
    select_delivery_time
  end

  def recalculate
    get_order_delivery
    update_details
    @order_delivery.calculate_total!
    # 常に edit を再表示
    render :action => "edit"
  end

  def update
    get_order_delivery
    #@order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    if @order_delivery.nil? || @order_delivery.order.retailer_id != session[:admin_user].retailer_id
      raise ActiveRecord::RecordNotFound
    end
    begin
      OrderDelivery.transaction do
        @order_delivery.update_attributes!(params[:order_delivery])
        @order_delivery.update_ticket(params[:order_delivery_ticket])
        complete_details
        flash.now[:notice] = "保存しました"
        redirect_to :action => 'index'
      end
    rescue => e
      @order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
      @order_delivery_ticket = @order_delivery.ticket_code
      select_delivery_time
      flash.now[:error] = "保存に失敗しました"
      render :action => 'edit'
    end
  end

  def statement
    @order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    @order_delivery.update_ticket(params[:order_delivery_ticket])
    @shop = Shop.find(:first)
  end

  def statement_download
    @order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    @shop = Shop.find(:first)
    
    report = ThinReports::Report.create do |r|
      r.use_layout "#{RAILS_ROOT}/public/admin/pdf_layout/statement" do |config|
        config.list(:product) do |c|
          c.events.on :footer_insert do |e|
            e.section.item(:subtotal).value(number_with_delimiter(@order_delivery.subtotal))
            e.section.item(:discount).value(number_with_delimiter(@order_delivery.discount) || 0)
            e.section.item(:deliv_fee).value(number_with_delimiter(@order_delivery.deliv_fee))
            e.section.item(:charge).value(number_with_delimiter(@order_delivery.charge))
            e.section.item(:delivery_total).value(number_with_delimiter(@order_delivery.total))
            e.section.item(:use_point).value(number_with_delimiter(@order_delivery.use_point))
            e.section.item(:add_point).value(number_with_delimiter(@order_delivery.add_point))
            e.section.item(:payment_total).value(number_with_delimiter(@order_delivery.payment_total))
          end
        end
      end

      r.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end

      r.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:page_total).value(e.report.page_count)
        end
      end
      
      r.start_new_page

      r.page.values(:recieve_date     => @order_delivery.received_at,
                    :order_code       => @order_delivery.order_code,
                    :create_date      => Time.now.strftime('%Y%m%d').to_date,
                    :customer_zipcode => "#{@order_delivery.zipcode01}-#{@order_delivery.zipcode02}",
                    :customer_address => "#{@order_delivery.prefecture_name}#{@order_delivery.address_city}#{@order_delivery.address_detail}",
                    :customer_name    => "#{@order_delivery.family_name} #{@order_delivery.first_name}",
                    :shop_zipcode     => @shop.try(:zipcode),
                    :shop_tel         => @shop.try(:tel),
                    :shop_address     => @shop.try(:address),
                    :shop_name        => @shop.try(:corp_name))
      
      @order_delivery.order_details.each do | detail |
        r.page.list(:product).add_row(:quantity       => detail.quantity,
                                      :product_name   => detail.product_name,
                                      :category_name1 => detail.style_category_name1,
                                      :category_name2 => detail.style_category_name2,
                                      :product_code   => detail.product_code,
                                      :price          => number_with_delimiter(detail.price),
                                      :price_with_tax => number_with_delimiter(detail.price_with_tax),
                                      :subtotal       => number_with_delimiter(detail.subtotal))
      end

      send_data r.generate,:filename    => "statement_#{@order_delivery.order_code}.pdf",
                           :type        => 'application/pdf',
                           :disposition => 'attachment'
    end
  end

  def picking_list
    get_search_form
   
    @order_deliveries = OrderDelivery.find(:all,
                                           :conditions => flatten_conditions(@search_list),
                                           :include    => OrderDelivery::DEFAULT_INCLUDE,
                                           :order      => "order_deliveries.id desc")
  end

  def picking_list_download
    @order_deliveries = OrderDelivery.find(:all,
                                           :order      => "order_deliveries.id desc", 
                                           :conditions => { :id => params[:order_ids].split(",") })

    report = ThinReports::Report.new :layout => "#{RAILS_ROOT}/public/admin/pdf_layout/picking_list"
  
    report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
    end

    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:page_total).value(e.report.page_count)
      end
    end
    
    report.start_new_page
    
    @order_deliveries.each do | order_delivery |
      order_delivery.order_details.each do | detail |
        report.page.list(:picking_list).add_row(:order_date     => order_delivery.received_at,
                                                :order_code     => order_delivery.order_code,
                                                :customer_name  => "#{order_delivery.family_name} #{order_delivery.first_name}",
                                                :status         => order_delivery.status_view,
                                                :product_code   => detail.product_code,
                                                :product_name   => detail.product_name,
                                                :category_name1 => detail.style_category_name1,
                                                :category_name2 => detail.style_category_name2,
                                                :quantity       => detail.quantity)
      end
    end

    send_data report.generate,:filename     => "PickingList_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf",
                              :type         => 'application/pdf',
                              :disposition  => 'attachment'
  end

  def destroy
    # 親と子も消す
    order_delivery = OrderDelivery.find(:first, :conditions => ["order_id=?", params[:id].to_i])
    begin
      raise if order_delivery.nil? || order_delivery.order.retailer_id != session[:admin_user].retailer_id
      order_delivery.order_details.each(&:destroy)
      order = order_delivery.order
      order_delivery.destroy
      order.destroy
      flash.now[:notice] = "削除しました"
    rescue
      flash.now[:error] = "削除に失敗しました"
    end
    redirect_to :action => "index"
  end

  def show
    get_order_delivery
    select_delivery_time
    if @order_delivery.nil?
      raise ActiveRecord::RecordNotFound
    end
    render :layout => false
  end

  def csv_download
    get_search_form
    csv_data, filename = Order.csv(@search_list)
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => Iconv.conv('cp932', 'UTF-8', csv_data)
  end

  private

  def select_delivery_time
    h = @order_delivery || params
    payment_id = h[:payment_id]
    @selected = h[:delivery_time_id]
    delivery_times = DeliveryTime.find(
      :all, :conditions => ["payments.id=? and delivery_times.name <> ''", payment_id],
      :include => [:delivery_trader=>:payments], :order => 'delivery_times.position')
    @options = [['指定なし', nil]]
    @options.concat(delivery_times.map do |dt|
      [dt.name, dt.id]
    end)
  end

  def get_order_delivery
    @order_delivery = OrderDelivery.find_by_order_id(params[:id].to_i)
    @order_delivery.attributes = params[:order_delivery]
  end

  def get_search_form
    addparam = {'retailer_id' => session[:admin_user].retailer_id}
    params[:search].merge! addparam unless params[:search].nil?
    @search = SearchForm.new(params[:search])
    @search, @search_list, @sex, @payment_id = Order.get_conditions(@search, params)
  end

  def list
    get_search_form
    
    find_options = {
      :page => params[:page],
      :per_page => @search.per_page || 10,
      :conditions => flatten_conditions(@search_list), 
      :include => OrderDelivery::DEFAULT_INCLUDE,
      :order => "order_deliveries.id desc"
    }
    @order_deliveries = OrderDelivery.paginate(find_options)
  end

  def update_details
    return if params[:detail].nil?
    @order_delivery.order_details.each do | detail |
      detail.attributes = params[:detail][detail.id.to_s]
    end
  end

  def complete_details
    return unless params[:detail]
    params[:detail].each do |id, values|
      order_detail = OrderDetail.find(id)
      order_detail.update_attributes!(values)
    end
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
