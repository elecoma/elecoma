require 'kconv'

class Admin::CampaignsController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_campaign
  before_filter :design_init, :only=>[:campaign_design, :campaign_design_update]

  PAGE_TYPE_PC_OPEN = "open_pc"
  PAGE_TYPE_PC_END = "end_pc"
  PAGE_TYPE_MOBILE_OPEN = "open_mobile"
  PAGE_TYPE_MOBILE_END = "end_mobile"

  index.before do
    @campaigns = Campaign.find(:all, :order => "id")
  end

  [create, update].each do |action|
    #action.before do
    #  @campaign.set_product_id
    #end

    action.wants.html do
      redirect_to :action => "index"
    end
  end

  def csv_download
    campaign = Campaign.find(params[:id])
    result = Campaign.csv(campaign)
    filename = "campaign#{params[:id]}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => Iconv.conv('cp932', 'UTF-8', result)
  end

  def campaign_design
    @type = params[:type]
    @id = params[:id]
    @campaign = Campaign.find(:first, :conditions=>["id=?", @id])
    get_form_names(@type)
  end

  def campaign_design_update
    @campaign.attributes = params[:campaign]
    @id = params[:id]
    @type = params[:type]

    get_form_names(@type)
    if @campaign.save
      flash[:camp_design] = "更新しました"
      redirect_to :action=>"campaign_design", :id=>@id, :type=>@type
    else
      flash[:camp_design_e] = "更新に失敗しました"
      render :action=>"campaign_design", :id=>@id, :type=>@type
    end
  end

  def campaign_preview
    @id = params[:id]
    @type = params[:type]
    @campaign = Campaign.find(:first, :conditions=>["id=?", @id])
    unless @campaign.product_id.blank?
      @product = @campaign.product
    end
    campaign = Campaign.new(params[:campaign])

    @free_spaces = Hash::new
    @free_space_names = []
    if /.*_mobile$/ =~ @type
      is_mobile = true
      if /^open_.*/ =~ @type
        @status = "open"
      else
        @status = "end"
      end
      3.times do |index|
        free_space_name = @type + "_free_space_" + (index+1).to_s
        @free_space_names << free_space_name
        @free_spaces[free_space_name] = campaign.attributes[free_space_name]
      end
      @mobile_device = MobileDevice.new
      @mobile_device.width = 640
    else
      is_mobile = false
      if /^open_.*/ =~ @type
        @status = "open"
      else
        @status = "end"
      end
      4.times do |index|
        free_space_name = @type + "_free_space_" + (index+1).to_s
        @free_space_names << free_space_name
        @free_spaces[free_space_name] = campaign.send(free_space_name)
      end
    end

    @admin_preview = true

    if is_mobile
      render :template => 'campaigns/show_mobile', :layout => 'base_mobile'
    else
      render :template => 'campaigns/show', :layout => 'base'
    end
  end

  private

  def design_init
    @campaign = Campaign.find_by_id(params[:id])
  end

  def get_form_names(type)
    @form_names = []

    case type
    when PAGE_TYPE_PC_OPEN
      @title = "PC用キャンペーン中ページデザイン編集"
      @form_names = ["open_pc_free_space_1", "open_pc_free_space_2", "open_pc_free_space_3", "open_pc_free_space_4"]
    when PAGE_TYPE_PC_END
      @title = "PC用キャンペーン終了ページデザイン編集"
      @form_names = ["end_pc_free_space_1", "end_pc_free_space_2", "end_pc_free_space_3", "end_pc_free_space_4"]
    when PAGE_TYPE_MOBILE_OPEN
      @title = "携帯用キャンペーン中ページデザイン編集"
      @form_names = ["open_mobile_free_space_1", "open_mobile_free_space_2", "open_mobile_free_space_3"]
    when PAGE_TYPE_MOBILE_END
      @title = "携帯用キャンペーン終了ページデザイン編集"
      @form_names = ["end_mobile_free_space_1", "end_mobile_free_space_2", "end_mobile_free_space_3"]
    end
  end

end
