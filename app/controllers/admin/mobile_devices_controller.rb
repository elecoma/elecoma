class Admin::MobileDevicesController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_mobile
  before_filter :list

  index.before do
    list
  end

  def search
    render :action => 'index'
  end

  new_action.wants.html do
    redirect_to :action => "index"
  end

  [create, update].each do |action|
    action.before do
      @mobile_device.attributes = params[:mobile_device]
    end

    action.wants.html do 
      redirect_to :action => "index"
    end

    action.failure.after do
      @mobile_device.remove_precent
    end

    action.failure.wants.html do
      unless @mobile_device.valid?
        render :action => "index"
      end
    end
  end

  private

  def list
    unless params[:id].blank?
      @mobile_device = MobileDevice.find_by_id(params[:id])
      @mobile_device.user_agent = remove_percent(@mobile_device.user_agent)
      @status = "update"
      @method = "put"
      @id = params[:id]
    else
      @mobile_device = MobileDevice.new
      @status = "create"
      @method = "post"
    end

    @search = SearchForm.new(params[:search])
    @search.mobile_carrier_id = @search.mobile_carrier_id.to_i if @search.mobile_carrier_id
    get_conditions
    @mobile_devices = MobileDevice.paginate(:all,
                        :conditions => flatten_conditions(@search_list||[]),
                        :order => "mobile_carrier_id,device_name",
                        :page => params[:page],
                        :per_page => 20)
  end

  def remove_percent(str)
    str.gsub(/%/, '')
  end
end
