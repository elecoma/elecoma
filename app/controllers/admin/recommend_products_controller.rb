class Admin::RecommendProductsController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_recommendation
  before_filter :master_shop_check

  index.before do
    @recommend_products = RecommendProduct.find(:all,
                                                :order => "position")
  end

  create.before do
    @recommend_product.position_up
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  #商品検索
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

    #結果表示
    @products = ProductStyle.paginate(:page=>params[:page],
                                 :conditions=>conditions,
                                 :order=>"products.id",
                                 :include => [:product, {:product => :category}],
                                 :per_page=>10)
    render :layout=> false
  end

end
