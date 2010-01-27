#入庫、在庫調整作業履歴
class Admin::StockHistoriesController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_stock
  
  def search
    @condition = StockSearchForm.new(params[:condition])
    unless @condition.valid?
      render :action => "index"
      return
    end

    @search_list = StockSearchForm.get_conditions(@condition)
    find_options = {
      :page => params[:page],
      :per_page => @condition.per_page || 10,
      :conditions => flatten_conditions(@search_list),
      :order => "id"
    }
    @stock_histories = StockHistory.paginate(find_options) 
  end
end
