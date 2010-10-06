# -*- coding: utf-8 -*-
class Payment < ActiveRecord::Base

  acts_as_paranoid
  acts_as_list
                 
  #belongs_to :delivery_trader
  belongs_to :resource, 
             :class_name => "ImageResource",
             :foreign_key => "resource_id"
  belongs_to :payment_plugin
  has_many :orders
  
  validates_presence_of :name,:fee#,:delivery_trader_id

  COMMON_DELIVERY_TRADER_ID = 0
  COMMON_DELIVERY_TRADER_NAME = "共通"

  def self.find_for_price_only_common_payment(price)
    conditions = ['(upper_limit is null or upper_limit >= ?)' +
                  ' and (lower_limit is null or lower_limit <= ?)' + 
                  ' and delivery_trader_id = ? ',
                  price, price, COMMON_DELIVERY_TRADER_ID]
    find(:all, :conditions => conditions, :order => 'position')
  end  

  def get_plugin_instance
    payment_plugin.get_plugin_instance
  end

  def common_delivery?
    return true if delivery_trader_id == COMMON_DELIVERY_TRADER_ID
    return false
  end

  def validate
    if !upper_limit.blank? && !lower_limit.blank? && upper_limit.to_i < lower_limit.to_i
      errors.add "","※ 利用条件(〜円以上)は利用条件(〜円以下)より大きい値を入力できません。"  
    end
    errors.add(:fee,"は0以上の整数で入力してください") unless self.fee.to_i >= 0
    errors.add(:lower_limit,"は0以上の整数で入力してください") unless self.lower_limit.to_i >= 0
    errors.add(:upper_limit,"は0以上の整数で入力してください") unless self.upper_limit.to_i >= 0
    
    errors.add(:fee,"は99,999,999円以下で入力してください") if self.fee.to_i >= 0 && self.fee.to_i>99999999
    errors.add(:lower_limit,"は99,999,999円で入力してください") if self.lower_limit.to_i >= 0 && self.lower_limit.to_i>99999999
    errors.add(:upper_limit,"は99,999,999円で入力してください") if self.upper_limit.to_i >= 0 && self.upper_limit.to_i>99999999
    unless self.payment_plugin_id.nil?
      instance = get_plugin_instance
      if instance.nil?
        errors.add(:payment_plugin, "が無効です。")
      else 
        ret, reason = instance.payment_validate(self)
        unless ret
          errors.add(:payment_plugin, reason)
        end
      end
    end
  end

  # 指定された価格に合う支払い方法の一覧
  def self.find_for_price(price)
    conditions = ['(upper_limit is null or upper_limit >= ?)' +
                  ' and (lower_limit is null or lower_limit <= ?)',
                  price, price]
    find(:all, :conditions => conditions, :order => 'position')
  end

  alias :resource_old= :resource=
  [:resource].each do  | method_name|
    define_method("#{method_name}=") do | value |
      if value.class == ActionController::UploadedStringIO || value.class == ActionController::UploadedTempfile || value.class == Tempfile
        image_resource = ImageResource.new_file(value, value.original_filename)
        self.send "#{method_name}_old=".intern, image_resource
      elsif value.class == ImageResource
        self.send "#{method_name}_old=".intern, value
      else
        nil
      end
    end
  end

end
