# -*- coding: utf-8 -*-
class FavoritesController < BaseController

  before_filter :login_check

  def delete_favorite
    return redirect_to(favorite_accounts_path) unless params[:product_order_unit_ids].is_a? Array

    params[:product_order_unit_ids].each do |product_order_unit_id|
      unless ProductOrderUnit.exists?(product_order_unit_id)
        flash[:error] = "商品ID[#{product_order_unit_id}]は存在しない商品IDです"
        return redirect_to(favorite_accounts_path)
      end

      favorite = Favorite.find(:first, :conditions => {:customer_id => @login_customer.id, :product_order_unit_id => product_order_unit_id})
      if favorite.nil?
        flash[:error] = "商品ID[#{product_order_unit_id}]はお気に入りに登録されていません"
        return redirect_to(favorite_accounts_path)
      end
    end

    begin
      Favorite.delete_all(:customer_id => @login_customer.id, :product_order_unit_id => params[:product_order_unit_ids].map(&:to_i))
      flash[:notice] = "削除しました"
    rescue
      flash[:error] = "削除に失敗しました"
    end
    redirect_to(favorite_accounts_path)
  end

  def add_favorite
    if params[:product_order_unit_id].blank?
      flash[:error] = "お気に入りへの追加に失敗しました"
      return redirect_to(favorite_accounts_path)
    end

    unless ProductOrderUnit.exists?(params[:product_order_unit_id])
      flash[:error] = "商品ID[#{params[:product_order_unit_id]}]は存在しない商品IDです"
      return redirect_to(favorite_accounts_path)
    end

    favorite = Favorite.create(:customer_id => @login_customer.id, :product_order_unit_id => params[:product_order_unit_id].to_i)
    unless favorite.errors.present?
      flash[:notice] = "商品をお気に入りに登録しました"
    else
      flash[:error] = favorite.errors.on(:product_order_unit_id)
    end
    redirect_to(favorite_accounts_path)
  end
end
