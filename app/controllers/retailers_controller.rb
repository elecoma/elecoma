class RetailersController < BaseController
  def index
    if !params[:id] or params[:id].to_i == Retailer::DEFAULT_ID
      redirect_to :controller => :portal, :action => :show
      return
    end
    @retailer = Retailer.find_by_id(params[:id])
    unless @retailer
      redirect_to :controller => :portal, :action => :show
      return
    end
  end
end
