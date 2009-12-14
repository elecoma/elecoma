class Admin::StyleCategoriesController < Admin::BaseController
  resource_controller

  index.before do
    @style_categories = StyleCategory.find(:all, 
                                           :conditions => ["style_id = ?", params[:style_id]],
                                           :order => "position")
    @style_category = StyleCategory.find_by_id(params[:id]) || StyleCategory.new({:style_id=>params[:style_id]})
  end

  new_action.wants.html do
    redirect_to :action => "index", :style_id => params[:style_id]
  end

  [create, update, destroy].each do |action|
    action.wants.html do
      redirect_to :action => "index", :style_id => params[:style_id]
    end

    action.failure.wants.html do
      @style_categories = StyleCategory.find(:all, 
                                             :conditions => ["style_id = ?", params[:style_id]],
                                             :order => "position")
      render :action => "index"
    end
  end

  def up
    super
    redirect_to :action => :index, :style_id => params[:style_id]
  end

  def down
    super
    redirect_to :action => :index, :style_id => params[:style_id]
  end

end
