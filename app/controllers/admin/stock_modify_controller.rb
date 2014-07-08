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
    @product_styles = session[:product_styles]
    @product_style = ProductStyle.find_by_id(params[:id])
    show_res(4) and return if @product_style.blank?
    #2.入力が半角数字のみか
    show_res(1) and return if params[:product_style][:actual_count] =~ /[^0-9]/
    @stock_history = StockHistory.new(params[:product_style])
    show_res(4) and return if @stock_history.blank?
    actual_count = @stock_history.actual_count.to_i
    #3.整数型範囲内か
    show_res(2) and return if actual_count >= 2**31
    #4.変更が必要か
    show_res(-1) and return if @product_style.actual_count == actual_count
    ps_init
    set_sh(actual_count)
    #5-1.入力チェック
    show_res(4) and return unless @stock_history.valid?
    #5-2.値チェック
    result,err_msg = check_parameter
    show_res(3) and return unless result
    #6.値設定
    set_parameter
    if @product_style.save
      set_stock_history
      @stock_history.save
      @sr_id = show_res(0)
    end
  end

  private
  def ps_init
    @product_style.actual_count = 0 if @product_style.actual_count.blank?
    @product_style.orderable_count = 0 if @product_style.orderable_count.blank?
    @product_style.broken_count = 0 if @product_style.broken_count.blank?
  end

  def set_sh(actual_count)
    @stock_history.actual_adjustment = actual_count - @product_style.actual_count
    @stock_history.orderable_adjustment = actual_count - @product_style.broken_count - @product_style.orderable_count
    @stock_history.stock_type = StockHistory::STOCK_MODIFY
    @stock_history.comment = "更新"
  end

  def show_res(e_id)
    @e_id = e_id
    respond_to do |format|
      format.js
    end
    true
  end

end
