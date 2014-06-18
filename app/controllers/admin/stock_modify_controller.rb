# -*- coding: utf-8 -*-
#在庫調整
class Admin::StockModifyController < Admin::StockBaseController
  before_filter :admin_permission_check_stock
  
  def index
    @condition = StockSearchForm.new(params[:condition])
  end

  def edit
    init(StockHistory::STOCK_MODIFY)
  end
  
  def update
    stock_update(StockHistory::STOCK_MODIFY)
  end
  
  #各調整数チェック
  def check_parameter
    result = false
    err_msg = nil
    
    actual_count = @product_style.actual_count.to_i + @stock_history.actual_adjustment.to_i
    orderable_count = @product_style.orderable_count.to_i + @stock_history.orderable_adjustment.to_i
    broken_count = @product_style.broken_count.to_i + @stock_history.broken_adjustment.to_i

    if [actual_count,orderable_count,broken_count].all? {|v| v >= 0}
      result = true
    else
      err = []
      if actual_count < 0
        err << "実在庫数"
      end
      if orderable_count < 0
        err << "販売可能数"
      end
      if broken_count < 0
        err << "不良在庫数"
      end
      err_msg = err.join("、") + "は0以下に設定できません。ご確認ください。"
    end
    [result,err_msg]
  end

  #値設定
  def set_parameter
    @product_style.actual_count = @product_style.actual_count.to_i +  @stock_history.actual_adjustment.to_i unless @stock_history.actual_adjustment.blank?
    @product_style.orderable_count = @product_style.orderable_count.to_i + @stock_history.orderable_adjustment.to_i unless @stock_history.orderable_adjustment.blank?
    @product_style.broken_count = @product_style.broken_count.to_i +  @stock_history.broken_adjustment.to_i   unless @stock_history.broken_adjustment.blank?
  end

  def edit_now
    #1.IDが有効か
    if !params[:id].blank? && params[:id]=~ /^\d*$/
      @product_style = ProductStyle.find_by_id(params[:id].to_i)
      @stock_history = StockHistory.new(params[:product_style])
      actual_count = @stock_history.actual_count.to_i
      if @product_style.actual_count.blank?
        @product_style.actual_count = 0
      end
      if @product_style.orderable_count.blank?
        @product_style.orderable_count = 0
      end
      if @product_style.broken_count.blank?
        @product_style.broken_count = 0
      end
      #2.変更が必要か
      if @product_style.actual_count != actual_count
        @stock_history.actual_adjustment = actual_count - @product_style.actual_count
        @stock_history.orderable_adjustment = actual_count - @product_style.broken_count - @product_style.orderable_count
        @stock_history.stock_type = StockHistory::STOCK_MODIFY
        @stock_history.comment = "更新"
        #3-1.入力チェック
        unless @stock_history.valid?
          render :update do |page|
            page.replace_html "msg"+params[:id].to_s, :text => "無効な値です"
          end
          raise StandardError
          return
        end
        #3-2.値チェック
        result,err_msg = check_parameter
        unless result
          render :update do |page|
            page.replace_html "msg"+params[:id].to_s, :text => err_msg
          end
          raise StandardError
          return
        end
        #4.値設定
        set_parameter
        if @product_style.save
          flash[:stock_editnow] = "更新しました"
          @stock_history.stock_type = StockHistory::STOCK_MODIFY
          @stock_history.comment = "更新"
          set_stock_history
          @stock_history.save
          render :update do |page|
            page.replace_html "act"+params[:id].to_s, :text => number_with_delimiter(actual_count)
          end
        else
          flash[:stock_editnow_e] = "更新に失敗しました"
        end
      end
    end
  end

  def edit_all
  end

end
