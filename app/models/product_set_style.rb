# -*- coding: utf-8 -*-
class ProductSetStyle < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :product_style

  delegate_to :product_style, :product
  delegate_to :product_style, :product, :id, :as => :product_id
  delegate_to :product_style, :product, :name, :as => :product_name
  delegate_to :product_style, :style_category1, :name, :as => :classcategory_name1
  delegate_to :product_style, :style_category2, :name, :as => :classcategory_name2

  def validate
    if quantity == 0
      errors.add :quantity, 'が 0 です。削除してください。'
    end
    unless product_style
      errors.add :product_style, 'がありません。削除してください。'
    end
  end
end

