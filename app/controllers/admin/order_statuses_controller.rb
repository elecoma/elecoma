# -*- coding: utf-8 -*-
require 'ostruct'

class Admin::OrderStatusesController < Admin::BaseController
  before_filter :admin_permission_check_receive_status

  def index
    @selected_status = params[:select] || OrderDelivery::YOYAKU_UKETSUKE
    list
  end

  # 選択された物のステータスを全て変更する
  def update
    if params[:id_array]
      begin
        OrderDelivery.transaction do
          params[:id_array].each do | id |
            if order_delivery = OrderDelivery.find_by_id(id)
              order_delivery.status = params[:new_status]
              order_delivery.update_ticket(params[:order_delivery_ticket_code][id])
              order_delivery.save!
            end
          end
          flash[:status] = "保存しました"
        end
      rescue
        flash[:status_e] = "保存に失敗しました"
      end
    end
    redirect_to :action => "index", :select => params[:select]
  end

  def csv_upload
    line = 0
    update_line = 0
    file = params[:upload_file]
    begin
      if CSVUtil.valid_data_from_file?(file)
        line, update_line, result = OrderDelivery.update_by_csv(file)
        unless result
          line = line + 1
          flash[:status] = "#{line}行目のデータが不正です。最初からやり直して下さい。"
          redirect_to :action => "index"
          return
        end
        if update_line == 0
          flash[:status] = "更新されたデータがありません。"
          redirect_to :action => "index"
          return
        end
        flash[:status] = "#{update_line}件のデータが登録されました"
        redirect_to :action => "index"
      else
        flash[:status] = "CSVファイルが空か、指定されたファイルが存在しません"
        redirect_to :action => "index"
      end
    rescue => e
      logger.error("order_statuses_controller#csv_upload catch error: " + e.to_s)
      flash[:status] = "エラーが発生しました。最初からやり直してく下さい。"
#      flash[:error] = e.to_s
      redirect_to :action => "index"
    end

  end

  private

  def list
    get_conditions
    @order_deliveries = OrderDelivery.paginate(
                          :page => params[:page],
                          :per_page => 10,
                          :conditions => flatten_conditions(@search_list),
                          :order => "id desc"
                                )
  end

  def get_conditions
    @search_list = []

    status = params[:select] || OrderDelivery::YOYAKU_UKETSUKE
    @search_list << ["status=?", status]
  end
end
