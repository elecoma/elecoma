# -*- coding: utf-8 -*-
#入庫管理
class Admin::StockInController < Admin::StockBaseController
  before_filter :admin_permission_check_stock
  
  def index
    @condition = StockSearchForm.new(params[:condition])
  end

  def edit
    init(StockHistory::STOCK_IN)
  end
  
  def update
    stock_update(StockHistory::STOCK_IN)
  end
  
  #各調整数チェック
  def check_parameter
    result = false
    err_msg = nil
    
    actual_count = @product_style.actual_count.to_i + @stock_history.storaged_count.to_i

    if actual_count >= 0
      result = true
    else
      err_msg = "実在庫数は0以下に設定できません。ご確認ください。"
    end
    [result,err_msg]
  end
  #値設定
  def set_parameter
    @product_style.actual_count = @product_style.actual_count.to_i +  @stock_history.storaged_count.to_i
  end
end
