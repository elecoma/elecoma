# -*- coding: utf-8 -*-
# 「カートに入れる」フォーム
class CartAddProductForm < SearchForm
  set_field_names :size => '個数'
  validates_presence_of :size,:message => 'が入力されていません。'
  validates_numericality_of :size, :greater_than_or_equal_to => 1, :only_integer => true, :allow_blank => true, :message => 'は 1 以上の数字（半角）を入力してください。'
end
