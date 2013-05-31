# -*- coding: utf-8 -*-
class OrderDetail < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :order_delivery
  belongs_to :product_style
  belongs_to :product_category, :class_name => 'Category'

  delegate_to :product_style, :product

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
    self.product_style_id = cart.product_style_id
    self.quantity = cart.quantity
    self.position = cart.position
    product_style = cart.product_style
    self.product_name = product_style.product.name
    self.product_code = product_style.code
    self.product_category_id = product_style.product.category_id
    self.price = product_style.sell_price
    self.style_category_name1 = product_style.style_category_name1
    self.style_category_name2 = product_style.style_category_name2
    self.style_name1 = product_style.style_name1
    self.style_name2 = product_style.style_name2
    self.product_id = product_style.product_id
    self.tax_price = 0 # 内税なので
  end

  # 商品名[ 規格名1[ 規格名2]] を出力
  def product_style_name(delimiter=' ')
    product_style.full_name(delimiter)
  end

end
