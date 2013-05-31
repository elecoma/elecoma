# -*- coding: utf-8 -*-
class NewInformation < ActiveRecord::Base

  acts_as_paranoid
  acts_as_list

  validates_presence_of :date
  validates_presence_of :name

  validates_length_of :name, :maximum=>200, :to_long=>"は最大%d文字です"
  validates_length_of :body, :maximum=>300, :to_long=>"は最大%d文字です"

  validates_format_of :url, :with=>%r{^(https?://\S*|)$}, :message=>"が不正です"

end
