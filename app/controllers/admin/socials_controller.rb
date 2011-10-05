# -*- coding: utf-8 -*-
class Admin::SocialsController < Admin::BaseController
  before_filter :master_shop_check
  before_filter :load_admin
  before_filter :admin_permission_check_social

  def index
    @shop = Shop.find(:first)
    @social = @shop.social || Social.new
  end

  def update
    @shop= Shop.find(:first)
    @social = @shop.social  || Social.new
    @social.attributes = params[:social]
    if @social.save
      flash[:notice] = "データを保存しました"
    else
      render :action => "index"
      return
    end
    redirect_to :action => "index"
  end

end
