# -*- coding: utf-8 -*-
class RecommendProduct < ActiveRecord::Base

  acts_as_paranoid
                  
  belongs_to :product
  
  validates_presence_of :product_id
  validates_presence_of :description
  validates_length_of :description, :maximum=>300, :to_long=>"は最大%d文字です", :allow_nil=>true

  def position_up
    if RecommendProduct.maximum(:position) != nil
      self.position = RecommendProduct.maximum(:position) + 1
    else
      self.position = 1
    end
  end
end
