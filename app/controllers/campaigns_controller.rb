class CampaignsController < BaseController
  before_filter :login_check, :only => [:complete, :show]
  def show
    btype = params[:btype]
    if btype.blank?
      if request.mobile?
        btype = "mobile"
      else
        btype = "pc"
      end
    end
    day = Time.now
    @campaign = Campaign.find(:first,
      :conditions => ["dir_name=? and opened_at < ? ", params[:dir_name], day])

    if !@campaign
      flash.now[:error] = "該当するキャンペーンがありません"
      return
    else
      @campaign_name = @campaign.name
      unless @campaign.product_id.blank?
        @product = @campaign.product
      end
      status_interface = design_status(@campaign, day, btype)
      @free_spaces = Hash::new
      @free_space_names = []
      if btype == "mobile"
        3.times do |index|
          free_space_name = status_interface + "_free_space_" + (index+1).to_s
          @free_space_names << free_space_name
          @free_spaces[free_space_name] = @campaign.attributes[free_space_name]
        end
      else
        4.times do |index|
          free_space_name = status_interface + "_free_space_" + (index+1).to_s
          @free_space_names << free_space_name
          @free_spaces[free_space_name] = @campaign.attributes[free_space_name]
        end
      end
    end
  end

  #応募人数の更新とcampaign_entryにレコードを追加
  def complete
    @id = params[:id]
    @campaign = Campaign.find(@id)
    @campaign.application_count = 0 if @campaign.application_count.blank?

    if @campaign.duplicated?(@login_customer)
      flash.now[:error] = "すでに応募されています"
      return
    end

    if @campaign.check_max_application_number
      @campaign.application_count += 1

      if @campaign.customers << @login_customer && @campaign.save
        flash.now[:notice] = "ご応募ありがとうございます"
      else
        flash.now[:error] = "応募に失敗しました"
      end
    else
      flash.now[:error] = "応募人数枠を越えてしまったため、応募できません"
    end
  end

  private

  #どのデザインを表示させるかを判定
  def design_status(campaign, day, btype)
    if request.mobile? || btype == "mobile"
      interface = "_mobile"
    else
      interface = "_pc"
    end

    if campaign.available?(day)
      @status = "open" #”応募するボタンを出すためのフラグ
      return "open" + interface
    else
      @status = "end"
      return "end" + interface
    end
  end
end
