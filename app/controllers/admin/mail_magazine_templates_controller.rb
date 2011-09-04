# -*- coding: utf-8 -*-
class Admin::MailMagazineTemplatesController < Admin::BaseController
  resource_controller
  mobile_filter
  emoticon_filter
  before_filter :admin_permission_check_template
  before_filter :master_shop_check

  new_action.before do
	  @mail_magazine_template.form = 2
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  def preview
    @mail_magazine_template = MailMagazineTemplate.find_by_id(params[:id].to_i) || MailMagazineTemplate.new
    unless @mail_magazine_template.id
      flash.now[:error] = "データがありません"
    end
    render :layout => false
  end

end
