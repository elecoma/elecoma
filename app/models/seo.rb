# -*- coding: utf-8 -*-
class Seo < ActiveRecord::Base

  acts_as_paranoid
  
  TOP, PRODUCTS_LIST, PRODUCTS_DETAIL, MYPAGE_INDEX = 0,1,2,3
  TYPE_NAMES = { TOP => 'TOPページ', PRODUCTS_LIST => '商品一覧ページ', PRODUCTS_DETAIL => '商品詳細ページ', MYPAGE_INDEX => 'MYページ' }
  
  validates_length_of :author,:description,:keywords, :maximum => 50, :allow_blank => true
  
  
  def before_save
    self.name=TYPE_NAMES[self.page_type]
  end
  
end
