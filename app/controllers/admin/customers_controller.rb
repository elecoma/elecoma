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
    unless session[:admin_user].master_shop?
      addparam = {'retailer_id' => session[:admin_user].retailer_id}
      params[:condition].merge! addparam unless params[:condition].nil?
    end
    @condition = CustomerSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => "index"
      return
    end
    sql_condition, conditions = CustomerSearchForm.get_sql_condition(@condition)
    sql = CustomerSearchForm.get_sql_select(true) + sql_condition
    sqls = [sql]
    conditions.each do |c|
      sqls << c
    end
    #condition_sql = CustomerSearchForm.get_sql_select + CustomerSearchForm.get_sql_condition(@condition)
    #@customers = Customer.paginate_by_sql(condition_sql,
    @customers = Customer.paginate_by_sql(sqls,
                                          :page => params[:page],
                                          :per_page => @condition.search_par_page,
                                          :order => "id")
  end

  edit.before do
    get_customer

    @order_count = Order.count(:conditions => ["customer_id=?", params[:id].to_i])
    @orders = Order.find(:all, :conditions => ["customer_id=?", params[:id].to_i],
      :include => :order_deliveries, :order => "orders.id,order_deliveries.id")
    get_admin_customer_payment
  end

  def confirm
    get_customer

    @order_count = params[:order_count]
    unless @customer.valid?
      # render 前には before_filter が働かないので自前で必要なメソッドを呼ぶ
      get_admin_customer_payment

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
        line, result = Customer.add_by_csv(file.path)
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
    @customer = Customer.find_by_id(params[:id].to_i)
    @customer.attributes = params[:customer]
  end

  def get_admin_customer_payment
    plugins = PaymentPlugin.find(:all, :conditions => ["enable = ? ", true], :order => :id)
    @admin_customer_payment_list = Array.new
    @admin_customer_payment_result = Hash.new
    plugins.each do |plugin|
      obj = plugin.get_plugin_instance
      key, value = obj.admin_customer_payment_result(@customer.id) if obj
      if key
        @admin_customer_payment_list << obj.admin_customer_payment_list
        @admin_customer_payment_result[key] = value
      end
    end
    @admin_customer_payment_list.flatten!
  end
end
