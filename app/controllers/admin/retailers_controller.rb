class Admin::RetailersController < Admin::BaseController
  resource_controller
  before_filter :master_shop_check, :only => [:index, :new]
  before_filter :admin_permission_check_member
  before_filter :load_admin
  before_filter :editable_check, :only => [:edit, :create, :update, :delete]

  index.before do
    @retailers = Retailer.find(:all,
                               :conditions => ["id != ?", Retailer::DEFAULT_ID],
                               :order => 'id')
  end
  [create, update].each do |action|
    action.wants.html do
      unless session[:admin_user].master_shop?
        redirect_to :action => "edit", :id => session[:admin_user].retailer_id
      else
        redirect_to :action => "index"
      end
    end
  end

  private

  def editable_check
    unless session[:admin_user].master_shop?
      if params[:id].to_i != session[:admin_user].retailer_id.to_i
        redirect_to :controller => "home", :action => "index"
        return false
      end
    end
  end

end
