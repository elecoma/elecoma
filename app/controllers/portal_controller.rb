# -*- coding: utf-8 -*-
class PortalController < BaseController

  def show
    load_new_information
    load_recommend_product
    load_seo
    load_new_product unless request.mobile?
    @recommend_xmls = Recommend.ranking_get(3)
		render :layout => false if request.mobile?
  end

  def show_tradelaw
    if params[:retailer_id]
      @law = Law.find_by_retailer_id(params[:retailer_id])
    end
    unless @law
      @law = Law.find_by_retailer_id(Retailer::DEFAULT_ID)
    end
    if @law.retailer_id == Retailer::DEFAULT_ID
      @shopname = Shop.find(:first).name
    else
      @shopname = Retailer.find(@law.retailer_id).name
    end
  end

  def privacy
    @privacy = Privacy.find(:first)
  end

  def first_one
    render :file => 'public/404.html', :status => :not_found unless request.mobile?
  end

  def company
  end

  def escape_clause
  end

  # info maintenance
  def maintenance
  end

  # information
  def notice
  end

  private
  def get_shop_info
    @shop = Shop.find(:first)
  end

  def load_new_information(character_id=nil)
    conds = []
    conds << ['date <= ? ', Time.now]
    @new_informations = NewInformation.find(:all,
      :conditions => flatten_conditions(conds),
      :order => "position")
  end

  def load_recommend_product
    @recommend_products = RecommendProduct.find(:all,
                                                :conditions=>["products.id >= ? and recommend_products.description <> ? and products.deleted_at is null", 1, ""],
                                                :include=>"product",
                                                :order => "recommend_products.position")
  end

  def load_new_product
    status = Status.find_by_name("NEW")
    conditions = Product.default_condition
    conditions << ["product_statuses.status_id = ?", status.id] if status
    @new_products = Product.find(:all,
                             :conditions => flatten_conditions( conditions ),
                             :joins => "left join product_statuses on product_statuses.product_id = products.id" ,
                             :include => Product::DEFAULT_INCLUDE,
                             :limit => 8,
                             :order => "id desc")
  end

  def load_seo
    @seo = Seo.find(:first, :conditions=>{ :page_type => Seo::TOP})
  end

end
