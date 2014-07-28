# -*- coding: utf-8 -*-
class OrderDetail < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :order_delivery
  belongs_to :product_order_unit
  belongs_to :product_category, :class_name => 'Category'

  delegate_to :product_order_unit, :product_style, :product

  # 税込価格(商品1個あたり)
  def price_with_tax
    price.to_i + tax_price.to_i
  end

  # 小計 (単価 + 税額) * 数)
  def subtotal
    (price.to_i + tax_price.to_i) * quantity.to_i
  end

  validates_presence_of :price, :quantity, :message => 'が入力されていません'

  def set_cart(cart)
    self.product_order_unit_id = cart.product_order_unit_id
    self.quantity = cart.quantity
    self.position = cart.position
    product_order_unit = cart.product_order_unit
    self.product_name = product_order_unit.ps.product.name
    if product_order_unit.is_set?
      self.product_code = product_order_unit.ps.code
      self.product_category_id = product_order_unit.ps.product.category_id
      self.price = product_order_unit.sell_price
      self.product_id = product_order_unit.ps.product_id
      self.product_style_ids = product_order_unit.ps.product_style_ids
      self.ps_counts = product_order_unit.ps.ps_counts
      self.tax_price = 0 # 内税なので
    else
      self.product_code = product_order_unit.ps.code
      self.product_category_id = product_order_unit.ps.product.category_id
      self.price = product_order_unit.sell_price
      self.style_category_name1 = product_order_unit.ps.style_category_name1
      self.style_category_name2 = product_order_unit.ps.style_category_name2
      self.style_name1 = product_order_unit.ps.style_name1
      self.style_name2 = product_order_unit.ps.style_name2
      self.product_id = product_order_unit.ps.product_id
      self.tax_price = 0 # 内税なので      
    end
  end

  # 商品名[ 規格名1[ 規格名2]] を出力
  def product_name(delimiter=' ')
    product_order_unit.sell_name
  end

end
