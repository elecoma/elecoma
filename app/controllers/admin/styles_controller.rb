class Admin::StylesController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_standard
  
  index.before do
    @styles = Style.find(:all, :order => "position")
    @style = Style.find_by_id(params[:id]) || Style.new
  end
  
  new_action.wants.html do
    redirect_to :action => "index"
  end

  [create, update, destroy].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end

    action.failure.wants.html do
      @styles = Style.find(:all, :order => "position")
      render :action => "index"
    end
  end

  def up
    super
    redirect_to :action => :index
  end

  def down
    super
    redirect_to :action => :index
  end

end
