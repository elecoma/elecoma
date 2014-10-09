# -*- coding: utf-8 -*-
class ReturnItem < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :product
  belongs_to :product_order_unit
  belongs_to :admin_user

  validates_presence_of :product_id
  validates_presence_of :product_order_unit_id
  validates_presence_of :admin_user_id
  validates_presence_of :comment
  validates_length_of :comment, :maximum => 10000, :allow_blank => true
  validates_presence_of :returned_at
  validates_presence_of :returned_count
  validates_numericality_of :returned_count, :greater_than_or_equal_to => 1, :message => "は1以上の数値で入力してください。"

  def is_set?
    self.product_order_unit.set_flag
  end
  
  def path_product
    is_set? ? product_order_unit.product_set :  product_order_unit.product_style
  end

end
