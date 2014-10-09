# -*- coding: utf-8 -*-
class Cart < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :customer
  belongs_to :product_order_unit

  delegate_to :product_order_unit, :product_style, :product
  delegate_to :product_order_unit, :product_set, :product
  delegate_to :product_order_unit, :product_style, :product, :id, :as => :product_id
  delegate_to :product_order_unit, :product_style, :product, :name, :as => :product_name
  delegate_to :product_order_unit, :product_set, :product, :name, :as => :product_name
  delegate_to :product_order_unit, :sell_price, :as => :price
  delegate_to :product_order_unit, :product_style, :style_category1, :name, :as => :classcategory_name1, :unless => :is_set?
  delegate_to :product_order_unit, :product_style, :style_category2, :name, :as => :classcategory_name2, :unless => :is_set?

  def subtotal
    if product_order_unit
      product_order_unit.including_tax_sell_price * quantity.to_i
    else
      nil
    end
  end

  def validate
    if customer && customer.black
      errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
    end
    if quantity == 0
      errors.add :quantity, 'が 0 です。削除してください。'
    end
    unless product_order_unit
      errors.add :product_order_unit, 'がありません。削除してください。'
    else
      # キャンペーンが生きているか
      if ps.product && campaign = ps.product.campaign
        unless campaign.check_term
          errors.add_to_base('キャンペーン期間外です。')
        end
      end
      product = product_order_unit.ps.product
      unless product.permit
        errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
      end
      unless product.in_sale_term?
        errors.add_to_base('申し訳ありませんが販売を終了させて頂きました。')
      end
    end
  end

  def is_set?
    self.product_order_unit.set_flag
  end

  def ps
    is_set? ? product_order_unit.product_set :  product_order_unit.product_style
  end  

end
