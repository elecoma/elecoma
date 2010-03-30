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

  private
  def object
    if not params[:id].blank?
      style_category = StyleCategory.find_by_id(params[:id])
      raise ActiveRecord::RecordNotFound unless style_category.style.retailer_id == session[:admin_user].retailer_id
    elsif params[:style_category] && params[:style_category][:style_id]
      style = Style.find(:all, :conditions => ["id = ? and retailer_id = ? ", params[:style_category][:style_id], session[:admin_user].retailer_id])
      raise ActiveRecord::RecordNotFound if style.nil? or style == []
    end
    super
  end

end
