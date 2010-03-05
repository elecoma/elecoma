# -*- coding: utf-8 -*-
class FeaturesController < BaseController
  def show
    #公開特集を取得
    @feature = Feature.find(:first,
      :conditions => ["dir_name = ? and permit = ?", params[:dir_name], true])

    if @feature.blank?
#      flash.now[:error] = "該当する特集がありません"
      if request.mobile?
        render :file => 'public/404_mobile.html'
      else
        render :file => 'public/404.html'
      end
      return
    else
      #特集が持っている商品一覧を取得
      if @feature.feature_type == Feature::PRODUCT
         @products = FeatureProduct.paginate(:page => params[:page],
                                              :per_page => 12,
                                              :conditions => ["feature_id = ?", @feature.id],
                                              :order => :position)
      end
    end
  end
end
