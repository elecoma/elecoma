class Admin::FeatureProductsController < Admin::BaseController
  #共通
  resource_controller
  before_filter :admin_permission_check_feature
  
  #indexの前処理
  index.before do
    @feature = Feature.find_by_id(params[:feature_id])
    if @feature
      @feature_products = @feature.feature_products
    else
      flash.now[:notice] = "特集が見つかりません"
      redirect_to :action => :index
    end
  end
  
  #newの前処理
  new_action.before do
    #@feature = Feature.find_by_id(params[:feature_id])
    @feature_product = FeatureProduct.new({:feature_id => params[:feature_id]})
    @feature_product.attributes = params[:feature_product]
  end
  
  #確認画面
  def confirm
    @feature_product = FeatureProduct.new(params[:feature_product])
    #入力チェック
    unless @feature_product.valid?
      render :action => :new
      return
    end
    #画像表示処理
    set_resource_old
  end
  
  #編集
  edit.before do
    @feature_product.attributes = params[:feature_product]
  end
  
  #商品登録用の商品検索
  def product_search
   
    @condition = SearchForm.new(params[:condition])

    unless @condition.searched == "true"
      render :layout=> false
      return false
    end

    cond = ""
    value = {}
    unless @condition.keyword.blank?
      cond += "products.name like :product_name"
      value[:product_name] = "%" + @condition.keyword + "%"
    end
    unless @condition.category_id.blank?
      cond += " and " unless @condition.keyword.blank?
      cond += "categories.id = :category_id"
      value[:category_id] = @condition.category_id
    end
    conditions = [cond, value]

    #検索結果
    @products = ProductStyle.paginate(:page=>params[:page],
                                 :conditions=>conditions,
                                 :order=>"products.id",
                                 :include => [:product, {:product => :category}],
                                 :per_page=>10)
    render :layout=> false
  end

  #確認画面表示前の画像表示処理
  def set_resource_old
    #画像入力欄に選択された場合のみ=>選択した画像
    #それ以外、商品一覧の画像で表示・登録
    product = Product.find_by_id(params[:feature_product][:product_id]) 
    small_resource = product.small_resource if product
    if params[:feature_product_image_resource_old_id] && params[:feature_product_image_resource_old_id] == 0.to_s && params[:feature_product][:image_resource].blank?
      @feature_product[:image_resource_id] = small_resource.id
    elsif params[:feature_product] && !params[:feature_product][:image_resource].blank?
      @feature_product[:image_resource] = params[:feature_product][:image_resource]
    elsif params[:feature_product] && !params[:feature_product][:image_resource_id].blank?
      @feature_product[:image_resource_id] = params[:feature_product][:image_resource_id]
    else
      @feature_product[:image_resource] = small_resource
    end
  end
  
  #遷移先指定
  [create, update, destroy].each do |action|
    action.wants.html do
      redirect_to :action => :index, :feature_id =>@feature_product.feature_id
    end
  end

end
