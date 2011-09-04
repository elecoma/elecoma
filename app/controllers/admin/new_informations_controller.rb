class Admin::NewInformationsController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_whats_new
  before_filter :master_shop_check

#  index.before do
#    @new_informations = NewInformation.find(:all, :order => "position")
#  end

  def index
    @new_informations = NewInformation.find(:all, :order => "position")
  end

  def confirm
    @new_information = NewInformation.find_by_id(params[:id].to_i) || NewInformation.new
    @new_information.attributes = params[:new_information]
    unless @new_information.valid?
      #redirect_to :action => (params[:id].blank? ? "new" : "edit")
      if params[:id].blank? and params[:new_information][:id].blank?
        render :action => "new"
      else
        render :action => "edit"
      end
    end
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  edit.before do
    #params[:id] = params[:id] || params[:new_information][:id]
    #p params[:id]
    unless params[:new_information].blank?
      @new_information = NewInformation.find_by_id(params[:new_information][:id].to_i)
      raise ActiveRecord::RecordNotFound unless @new_information
      @new_information.attributes = params[:new_information]
      params[:id] = params[:new_information][:id].to_i
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

  def change_position
    super
    #format.html {redirect_to :action => "index"}
    redirect_to :action => "index"
  end

end
