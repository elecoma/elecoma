# -*- coding: utf-8 -*-
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
      if params[:id].to_i == session[:admin_user].id
        if AdminUser.find(params[:id].to_i).retailer_id != session[:admin_user].retailer_id
          redirect_to :controller => "admin/accounts", :action => "logout"
        else
          redirect_to :action => "index"
        end
      else
        redirect_to :action => "index"
      end
    end
  end

  destroy.before do
    if session[:admin_user].id == params[:id].to_i
      raise "You can't delete yourself"
    end
  end

  edit.before do
    unless session[:admin_user].master_shop?
      raise ActiveRecord::RecordNotFound if AdminUser.find(params[:id].to_i).retailer_id != session[:admin_user].retailer_id
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
    record = AdminUser.find_by_id(params[:id].to_i)
    if params[:activity] == "true"
      record.update_attribute(:activity, true)
    elsif params[:activity] == "false"
      record.update_attribute(:activity, false)
    end
    render :text=>true
  end
end
