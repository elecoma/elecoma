# -*- coding: undecided -*-
class Retailer < ActiveRecord::Base

  has_many :product
  validates_presence_of :name
  validates_format_of :name_kana, :with => System::KATAKANA_PATTERN
  #DEFAULT_IDは標準の販売元として利用
  DEFAULT_ID = 1

end
