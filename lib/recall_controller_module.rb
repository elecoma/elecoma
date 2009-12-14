# RecallController と RecallStatusController で使うもの
module RecallControllerModule
  private

  def prepare
    get_model 
    get_list_view
    get_order
    get_conditions

    @search = SearchForm.new(params[:search])
    inc = [:recall=>{:order_delivery=>:order}]
    @find_options = {
      :page => params[:page],
      :per_page => (params[:search]||params)[:per_page] || 10,
      :conditions => flatten_conditions(@search_list),
      :include => inc,
      :order => @order
    }
  end
end
