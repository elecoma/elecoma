class Admin::AdminUsersController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_member
  before_filter :load_admin
 
  index.before do
    if session[:admin_user].master_shop?
      @admin_users = AdminUser.find(:all,
                                    :order => 'position')
    else
      @admin_users = AdminUser.find(:all, 
                                    :conditions => ["retailer_id = ?", session[:admin_user].retailer_id], 
                                    :order => 'position')
    end
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  edit.before do
    unless session[:admin_user].master_shop?
      raise ActiveRecord::RecordNotFound if AdminUser.find(params[:id]).retailer_id != session[:admin_user].retailer_id
    end
  end

  def up
    super
    redirect_to :action => "index"
  end
  def down
    super
    redirect_to :action => "index"
  end

  #稼働/非稼働チェック(Ajax)
  def update_activity
    record = AdminUser.find_by_id(params[:id])
    if params[:activity] == "true"
      record.update_attribute(:activity, true)
    elsif params[:activity] == "false"
      record.update_attribute(:activity, false)
    end
    render :text=>true
  end
end
