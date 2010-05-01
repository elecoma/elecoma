class Admin::RetailersController < Admin::BaseController
  resource_controller
  before_filter :master_shop_check
  before_filter :admin_permission_check_member
  before_filter :load_admin

  index.before do
    @retailers = Retailer.find(:all,
                               :order => 'id')
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

end
