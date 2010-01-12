class Admin::CategoriesController < Admin::BaseController
  resource_controller

  index.before do
    @category = Category.find_by_id(params[:id])
    if @category
      params[:category_id] ||= @category.parent_id 
    end

    @categories = Category.get_list(params[:category_id])
    @category ||= Category.new
  end

  [create, update, destroy].each do |action|
    action.wants.html do
      redirect_to :action => "index", :category_id => @category.parent_id
    end
  end

  def up
    super
    redirect_to :action => "index", :category_id => @record.parent_id
  end

  def down
    super
    redirect_to :action => "index", :category_id => @record.parent_id
  end
end
