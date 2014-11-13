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

    #結果表示
    @pous = ProductOrderUnit.all
    unless @condition.keyword.blank?
      @pous.select! {|pou| pou.ps.product.name.include?(@condition.keyword) }
    end
    unless @condition.category_id.blank?
      @pous.select! {|pou| pou.ps.product.category_id == @condition.category_id.to_i}
    end
    @products = @pous.paginate(:page=>params[:page],
        :order=>"product_order_units.id",
        :per_page=>10)

    render :layout=> false
  end

end
