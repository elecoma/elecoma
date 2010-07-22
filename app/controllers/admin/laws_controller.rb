class Admin::LawsController < Admin::BaseController
  before_filter :admin_permission_check_commerce_low
  
  def index
    @law = Law.find_by_retailer_id(session[:admin_user].retailer_id)
    unless @law
      @law = Law.new
    end
  end

  def update
    @law = Law.find_by_retailer_id(session[:admin_user].retailer_id)
    unless @law
      @law = Law.new
      @law.retailer_id = session[:admin_user].retailer_id
    end
    @law.attributes = params[:law]

    unless @law.valid?
      flash.now[:error] = "保存に失敗しました"
      render :action => "index"
      return
    end
    if @law && @law.save
      flash.now[:notice] = "データを保存しました"
    else
      flash.now[:error] = "保存に失敗しました"
    end
    redirect_to :action => "index"
  end

end
