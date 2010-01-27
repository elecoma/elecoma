#在庫管理の親クラス
#共通ロジック
class Admin::StockBaseController < Admin::BaseController
  before_filter :admin_permission_check_stock
  
  #検索
  def search
    @condition = StockSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => "index"
      return
    end
    @condition, @search_list = Product.get_conditions(@condition, params, true)
    find_options = {
      :page => params[:page],
      :per_page => @condition.per_page || 10,
      :conditions => flatten_conditions(@search_list),
      :joins => "LEFT JOIN products ON products.id = product_styles.product_id ",
      :order => "product_styles.id"
    }
    @product_styles = ProductStyle.paginate(find_options)    
  end
  
  #入庫数、在庫数を更新
  def stock_update(stock_type)
    #1.初期データ取得
    init(stock_type)
    #2-1.入力チェック
    unless @stock_history.valid?
      render :action => "edit"
      return
    end
    #2-2.値チェック
    result,err_msg = check_parameter
    unless result
      flash.now[:error] = err_msg
      render :action => "edit"
      return
    end
    #3.値設定
    set_parameter
    #4-1. 商品規格保存
    if @product_style.save!
      #4-2.作業履歴保存
      set_stock_history
      @stock_history.save
      flash[:stock_update] = "データを保存しました"
      redirect_to :action => "index"
    else  
      flash[:stock_update_e] = "データ保存に失敗しました"
      render :action => "edit"
      return
    end
  end
  
  protected
  def init(stock_type)
    if !params[:id].blank? && params[:id]=~ /^\d*$/ 
      @product_style = ProductStyle.find_by_id(params[:id].to_i)
      if !@product_style.blank?
        @stock_history = StockHistory.new(params[:stock_history])
        @stock_history.stock_type = stock_type
      else      
        raise ActiveRecord::RecordNotFound
      end
    else
      raise "Parameter Invalid"
    end
  end
  
  #保存したい作業履歴値設定
  def set_stock_history
    @stock_history.admin_user_id = session[:admin_user].id
    @stock_history.product_id = @product_style.product_id
    @stock_history.product_style_id = @product_style.id
    @stock_history.actual_count = @product_style.actual_count
    @stock_history.orderable_count = @product_style.orderable_count
    @stock_history.broken_count = @product_style.broken_count
    @stock_history.moved_at = DateTime.now
  end 
end
