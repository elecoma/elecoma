# -*- coding: utf-8 -*-
class DeliveryFee < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :delivery_trader
  belongs_to :prefecture
  MAX_SIZE = 48

  validates_presence_of :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0

  def prefecture_name
    if prefecture
      prefecture.name
    else
      '離島'
    end
  end

end
