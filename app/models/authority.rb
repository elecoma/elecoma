# -*- coding: utf-8 -*-
class Authority < ActiveRecord::Base
  
  acts_as_list
  
  has_many :admin_users
  has_and_belongs_to_many :functions
  
  #前処理
  before_create :position_up
  
  validates_presence_of :name, :message=>'を入力してください'
  validates_uniqueness_of :name, :message=>'は、重複しています'
  
  def chang_functions(selected_functions)
    function_ids = selected_functions.keys.collect {|key| key.to_i}
    self.functions = Function.find(function_ids)
  end
  
  protected
  
  def position_up
    if Authority.maximum(:position) != nil
      self.position = Authority.maximum(:position) + 1
    else
      self.position = 1
    end
  end
  
  
end
