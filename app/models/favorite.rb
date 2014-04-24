# -*- coding: utf-8 -*-
class Favorite < ActiveRecord::Base

  MAX_PER_PAGE = 20

  acts_as_paranoid

  belongs_to :customer
  belongs_to :product_style

  validates_presence_of :customer_id,:product_style_id
  validates_numericality_of :customer_id,:product_style_id,:allow_blank => true

  validates_uniqueness_of :product_style_id, :scope => :customer_id, :message => "この商品ははすでに登録されています"

end
