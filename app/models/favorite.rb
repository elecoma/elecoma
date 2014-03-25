# -*- coding: utf-8 -*-
class Favorite < ActiveRecord::Base
  MAX_PER_PAGE = 20

  acts_as_paranoid

  belongs_to :customer
  belongs_to :product_style

  validates_presence_of :customer_id,:product_style_id
  validates_numericality_of :customer_id,:product_style_id,:allow_blank => true

  def validate
    #同じ商品を登録できない
    if Favorite.find(:all,:conditions => {:customer_id => customer_id,:product_style_id => product_style_id}).present?
      errors.add_to_base('既にお気に入りに登録されています')
    end
  end
end
