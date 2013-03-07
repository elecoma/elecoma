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
end
