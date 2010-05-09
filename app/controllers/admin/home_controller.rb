class Admin::HomeController < Admin::BaseController
  before_filter :admin_login_check
	#include AdminControllerModule

  def index
    ### 検索に必要な日付 ここから###
    # 今日
    today = Date.today
    # 昨日
    yesterday = today - 1
    # 今月の１日
    today_one = Date.new(today.year, today.month, 1)
    ### 検索に必要な日付 ここまで###

    #ショップの状況
    #現在の会員数
    @active_customer_num = Customer.count(:conditions=>["activate=?", Customer::TOUROKU])
    #昨日の受注金額
    @last_day_sales = OrderDelivery.sum(:payment_total,
                                        :joins =>"LEFT JOIN orders ON order_deliveries.order_id = orders.id",
                                        :conditions => ["(? <= orders.received_at and orders.received_at < ?) and order_deliveries.status in (?, ?, ?, ?) and orders.retailer_id = ?",
                                        yesterday.to_s, today.to_s, OrderDelivery::JUTYUU, OrderDelivery::HASSOU_TEHAIZUMI, OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO, session[:admin_user].retailer_id])

    #昨日の受注件数
    @last_day_sales_num = OrderDelivery.count(:joins => "LEFT JOIN orders ON order_deliveries.order_id = orders.id",
                                              :conditions=>["(? <= orders.received_at and ? > orders.received_at) and (status in (?, ?, ?, ?)) and orders.retailer_id = ?",
                                              yesterday.to_s, today.to_s, OrderDelivery::JUTYUU, OrderDelivery::HASSOU_TEHAIZUMI, OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO, session[:admin_user].retailer_id])
    #今月の受注金額(昨日まで)
    @this_month_sales = OrderDelivery.sum(:payment_total,
                                        :joins =>"LEFT JOIN orders ON order_deliveries.order_id = orders.id",
                                        :conditions => ["(? <= orders.received_at and orders.received_at < ?) and order_deliveries.status in (?, ?, ?, ?) and orders.retailer_id = ?",
                                        today_one.to_s, today.to_s, OrderDelivery::JUTYUU, OrderDelivery::HASSOU_TEHAIZUMI, OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO, session[:admin_user].retailer_id])

    #今月の受注件数 (昨日まで)
    @this_month_sales_num = OrderDelivery.count(:joins => "LEFT JOIN orders ON order_deliveries.order_id = orders.id",
                                                :conditions=>["(? <= orders.received_at and orders.received_at < ?) and (order_deliveries.status in (?, ?, ?, ?)) and orders.retailer_id = ?",
                                                today_one.to_s, today.to_s, OrderDelivery::JUTYUU, OrderDelivery::HASSOU_TEHAIZUMI, OrderDelivery::HASSOU_TYUU, OrderDelivery::HAITATU_KANRYO, session[:admin_user].retailer_id])
    #品切れ商品
    @sold_outs = ProductStyle.find(:all, :conditions => <<-EOS,
                   product_styles.actual_count <= 0 or product_styles.actual_count is null and products.retailer_id = #{session[:admin_user].retailer_id}
                   EOS
                   :joins => "LEFT JOIN products ON products.id = product_styles.product_id ",
                   :select => "products.name, product_styles.code",
                   :order => "products.id")

    @new_orders = OrderDelivery.find(:all, 
                                     :conditions => ["orders.retailer_id = ?", session[:admin_user].retailer_id], 
                                     :joins => "LEFT JOIN orders ON order_deliveries.order_id = orders.id", 
                                     :order=>"order_deliveries.created_at DESC", 
                                     :limit=>10)
  end
end
