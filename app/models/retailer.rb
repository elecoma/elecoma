# -*- coding: undecided -*-
class Retailer < ActiveRecord::Base

  has_many :product
  belongs_to :prefecture
  
  validates_presence_of :name
  validates_format_of :name_kana, :with => System::KATAKANA_PATTERN
  validates_format_of :corp_name_kana, :with => System::KATAKANA_PATTERN

  
  validates_numericality_of :zipcode01, :zipcode02, :allow_blank => true
  validates_length_of :zipcode01, :maximum => 3, :allow_blank => true
  validates_length_of :zipcode02, :maximum => 4, :allow_blank => true
 

  validates_length_of :address_city, :address_details, :maximum => 50, :allow_blank => true
  validates_inclusion_of :prefecture_id, :in => 1..47,:message => "を選択してください", :allow_blank => true

  validates_length_of :businesstime, :maximum => 50, :allow_blank => true

  validates_length_of :mail_faq,:mail_sender,:mail_admin, :maximum => 50, :allow_blank => true

  validates_length_of :trade_item,:introduction, :maximum => 99999, :allow_blank => true

  validates_length_of :tel01,:tel02,:tel03, :fax01,:fax02, :fax03, :maximum => 6, :allow_blank => true


  belongs_to :resource,
             :class_name => "ImageResource",
             :foreign_key => "resource_id"
  belongs_to :menu_resource,
             :class_name => "ImageResource",
             :foreign_key => "menu_resource_id"

  alias :resource_old= :resource=
  alias :menu_resource_old= :menu_resource=
  [:resource, :menu_resource].each do  | method_name|
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

  def validate
    if !self.tel01.nil? and self.tel01.size > 0
      unless  self.tel01 =~ /^(\d+)$/
        errors.add(:tel01, "を正しく入力してください")
      end
    end
    if !self.tel02.nil? and self.tel02.size > 0
      unless  self.tel02 =~ /^(\d+)$/
        errors.add(:tel02, "を正しく入力してください")
      end
    end
    if !self.tel03.nil? and self.tel03.size > 0
      unless  self.tel03 =~ /^(\d+)$/
        errors.add(:tel03, "を正しく入力してください")
      end
    end
    if !self.fax01.nil? and self.fax01.size > 0
      unless  self.fax01 =~ /^(\d+)$/
        errors.add(:fax01, "を正しく入力してください")
      end
    end
    if !self.fax02.nil? and self.fax02.size > 0
      unless  self.fax02 =~ /^(\d+)$/
        errors.add(:fax02, "を正しく入力してください")
      end
    end
    if !self.fax03.nil? and self.fax03.size > 0
      unless  self.fax03 =~ /^(\d+)$/
        errors.add(:fax03, "を正しく入力してください")
      end
    end
  end


  
  #DEFAULT_IDは標準の販売元として利用
  DEFAULT_ID = 1



  # 表示系メソッド
  def tel
    "#{tel01}-#{tel02}-#{tel03}"
  end

  def fax
    "#{fax01}-#{fax02}-#{fax03}"
  end

  def zipcode
    "#{zipcode01}-#{zipcode02}"
  end

  def address
    prefecture.try(:name) + address_city + address_details unless prefecture.nil?
  end

end
