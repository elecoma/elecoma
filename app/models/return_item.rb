# -*- coding: utf-8 -*-
class ReturnItem < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :product
  belongs_to :product_style
  belongs_to :admin_user

  validates_presence_of :product_id
  validates_presence_of :product_style_id
  validates_presence_of :admin_user_id
  validates_presence_of :comment
  validates_length_of :comment, :maximum => 10000, :allow_blank => true
  validates_presence_of :returned_at
  validates_presence_of :returned_count
  validates_numericality_of :returned_count, :greater_than_or_equal_to => 1, :message => "は1以上の数値で入力してください。"

end
