class Admin::DesignsController < Admin::BaseController
  before_filter :admin_permission_check_pc_edit, :only => [:index, :pc, :update]
  before_filter :admin_permission_check_mobile_edit, :only => :mobile
  before_filter :master_shop_check

  def index
    redirect_to :action => 'pc'
  end

  def pc
    @design = Design.first || Design.new
  end

  def update_pc
    @design = Design.first || Design.new

    if @design.update_attributes(params[:design])
      flash.now[:notice] = '保存しました。'
      redirect_to :action => :pc
    else
      flash.now[:errors] = "保存に失敗しました"
      render :action => :pc
    end
  end

  def mobile
    @design = Design.first || Design.new
  end

  def update_mobile
    @design = Design.first || Design.new

    if @design.update_attributes(params[:design])
      flash.now[:notice] = "保存しました"
    else
      flash.now[:errors] = "保存に失敗しました"
    end

    redirect_to :action => "mobile"
  end

end
