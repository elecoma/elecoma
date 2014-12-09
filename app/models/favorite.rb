# -*- coding: utf-8 -*-
class Favorite < ActiveRecord::Base

  MAX_PER_PAGE = 20

  acts_as_paranoid

  belongs_to :customer
  belongs_to :product_order_unit

  validates_presence_of :customer_id,:product_order_unit_id
  validates_numericality_of :customer_id,:product_order_unit_id,:allow_blank => true
  validates_uniqueness_of :product_order_unit_id, :scope => :customer_id, :message => "この商品ははすでに登録されています"

  def ps_path
    is_set? ? product_order_unit.product_set :  product_order_unit.product_style
  end
  def is_set?
    self.product_order_unit.set_flag
  end

end
