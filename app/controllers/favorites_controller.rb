# -*- coding: utf-8 -*-
class FavoritesController < BaseController

  before_filter :login_check, :except => [ :product_id_check]

  def product_id_check(product_style_id)
    product = ProductStyle.find_by_id(product_style_id)
    flash[:error] = "商品ID[#{product_style_id}]は存在しない商品IDです" if product.nil?
    return product
  end

  def delete_favorite
    return redirect_to('/accounts/favorite') unless params[:product_style_ids].is_a? Array

    params[:product_style_ids].each do |product_style_id|
      product = product_id_check(product_style_id)
      return redirect_to('/accounts/favorite') if product.nil?

      favorite = Favorite.find(:first, :conditions => {:customer_id => @login_customer.id, :product_style_id => product_style_id})
      if favorite.nil?
        flash[:error] = "商品ID[#{product_style_id}]はお気に入りに登録されていません"
        return redirect_to('/accounts/favorite')
      end
    end

    begin
      Favorite.delete_all(:customer_id => @login_customer.id, :product_style_id => params[:product_style_ids].map(&:to_i))
      flash[:notice] = "削除しました"
    rescue
      flash[:error] = "削除に失敗しました"
    end
    redirect_to('/accounts/favorite')
  end

  def add_favorite
    product = product_id_check(params[:product_style_id])
    return redirect_to('/accounts/favorite') if product.nil?

    if params[:product_style_id].blank?
      flash[:error] = "お気に入りへの追加に失敗しました"
      return redirect_to('/accounts/favorite')
    end

    favorite = Favorite.create(:customer_id => @login_customer.id, :product_style_id => params[:product_style_id].to_i)
    unless favorite.errors.present?
      flash[:notice] = "商品をお気に入りに登録しました"
    else
      flash[:error] = favorite.errors.on(:product_style_id)
    end
    redirect_to('/accounts/favorite')
  end
end
