module Admin::CampaignsHelper
  def is_open
    if(@type == Admin::CampaignsController::PAGE_TYPE_PC_OPEN || @type == Admin::CampaignsController::PAGE_TYPE_MOBILE_OPEN)
      return true
    end
    return false
  end

  def is_pc
    if(@type == Admin::CampaignsController::PAGE_TYPE_PC_OPEN || @type == Admin::CampaignsController::PAGE_TYPE_PC_END)
      return true
    end
    return false
  end
end
