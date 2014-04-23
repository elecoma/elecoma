# -*- coding: utf-8 -*-
class FavoritesController < BaseController

  def delete_favorite
    if @login_customer
      if params[:product_style_ids].is_a? Array
        begin
          Favorite.delete_all(:customer_id => @login_customer.id, :product_style_id => params[:product_style_ids].map(&:to_i))
          flash[:notice] = "削除しました"
        rescue
          flash[:error] = "削除に失敗しました"
        end
      end
    end
    redirect_to(:controller => 'accounts', :action => 'favorite')
  end

  def add_favorite
    if @login_customer
      if params[:product_style_id].blank?
        flash[:error] = "お気に入りへの追加に失敗しました"
        return redirect_to(:controller => 'accounts', :action => 'favorite')
      end

      favorite = Favorite.create(customer_id: @login_customer.id, product_style_id: params[:product_style_id].to_i)
      if favorite.errors.present?
        flash[:error] = favorite.errors.on(:product_style_id)
      else
        flash[:notice] = "商品をお気に入りに登録しました"
      end
    end
    redirect_to(:controller => 'accounts', :action => 'favorite')
  end
end
