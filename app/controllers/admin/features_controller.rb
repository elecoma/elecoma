class Admin::FeaturesController < Admin::BaseController
  #共通
  resource_controller
  before_filter :admin_permission_check_feature
  
  #indexの前処理
  index.before do
    @feature = Feature.new
    @features = Feature.find(:all, :order => "id")
  end
  
  #newの前処理
  new_action.before do
    @feature = Feature.new(params[:feature])
  end
  
  #編集
  edit.before do
    @feature.attributes = params[:feature]
  end

  #遷移先指定  
  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  #確認画面
  def confirm
    if params[:id]
      @feature = Feature.find_by_id(params[:id])
      @feature.attributes = params[:feature]
    else  
      @feature = Feature.new(params[:feature])
    end
    set_resource_old
    #入力チェック
    unless @feature.valid?
      render :action => :new
      return
    end
  end
  
  #確認画面表示前の画像表示処理
  def set_resource_old
    image_resource_id = params["feature_image_resource_old_id".intern]
    if image_resource_id.to_s == 0.to_s
      if params[:feature][:image_resource].blank?
        @feature["image_resource_id".intern] = nil
      else
        @feature[:image_resource] = params[:feature][:image_resource]
      end
    else
      @feature["image_resource_id".intern] = image_resource_id unless params[:feature][:image_resource]
    end
  end
  
end
