# -*- coding: utf-8 -*-
require 'pp'
require 'csv'
require 'kconv'

class Admin::CustomersController < Admin::BaseController
  before_filter :admin_permission_check_customer
  resource_controller

  index.before do
    @condition = CustomerSearchForm.new({})
  end

  def search
    @condition = CustomerSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => "index"
      return
    end
    condition_sql = CustomerSearchForm.get_sql_select + CustomerSearchForm.get_sql_condition(@condition)
    @customers = Customer.paginate_by_sql(condition_sql,
                                          :page => params[:page],
                                          :per_page => @condition.search_par_page,
                                          :order => "id")
  end

  edit.before do
    get_customer

    @order_count = Order.count(:conditions => ["customer_id=?", params[:id]])
    @orders = Order.find(:all, :conditions => ["customer_id=?", params[:id]],
      :include => :order_deliveries, :order => "orders.id,order_deliveries.id")
  end

  def confirm
    get_customer

    @order_count = params[:order_count]
    unless @customer.valid?
      render :action => :edit, :id => @customer.id
    end
  end

  update.wants.html do
    redirect_to :action => :index
  end

  def csv_download
    csv_data = CustomerSearchForm.csv(params)
    unless csv_data
      flash.now[:notice] = 'ダウンロード対象データが１件もありませんでした'
      render :action => :index
      return
    end
    file_name = "customers_" + Time.now.strftime('%Y%m%d%H%M%S') + ".csv"
    send_data csv_data.tosjis, :type => 'text/csv; charset=Shift_JIS', :filename => file_name
  end

  def csv_upload
    line = 0
    file = params[:upload_file]

    begin
      if CSVUtil.valid_data_from_file?(file)
        line, result = Customer.add_by_csv(file)
        unless result
          line = line + 1
          flash.now[:notice] = "#{line}行目のデータが不正です。最初からやり直して下さい。"
          redirect_to :action => "index"
          return
        end
        flash.now[:notice] = "#{line}件のデータが登録されました"
        redirect_to :action => "index"
      else
        flash.now[:notice] = "CSVファイルが空か、指定されたファイルが存在しません"
        redirect_to :action => "index"
      end
    rescue => e
      logger.error("custermers_controller#csv_upload catch error: " + e.to_s)
      flash.now[:notice] = "エラーが発生しました。最初からやり直して下さい。"
      redirect_to :action => "index"
    end
  end

  private

  def get_customer
    @customer = Customer.find_by_id(params[:id])
    @customer.attributes = params[:customer]
  end

end





