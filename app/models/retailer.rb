# -*- coding: undecided -*-
class Retailer < ActiveRecord::Base

  has_many :product
  validates_presence_of :name

  #DEFAULT_IDは標準の販売元として利用
  DEFAULT_ID = 1

end
