# -*- coding: utf-8 -*-
class StockHistory < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :product
  belongs_to :product_style
  belongs_to :admin_user
  
  validates_presence_of :comment
  validates_length_of :comment, :maximum => 10000 , :allow_blank => true
  validates_presence_of :storaged_count ,:if => :stock_in?
  
  STOCK_IN ,STOCK_MODIFY = 1 , 2 
  STOCK_TYPE_NAMES = {STOCK_IN=>"入庫",STOCK_MODIFY=>"在庫調整"}
  
  def stock_in?
    stock_type == STOCK_IN
  end   
end
