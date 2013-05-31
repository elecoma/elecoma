# -*- coding: utf-8 -*-
class Shop < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :prefecture
  has_one :social

  validates_presence_of :name, :corp_name
  validates_length_of :name,:name_kana,:corp_name,:corp_name_kana, :maximum => 50
  validates_format_of :name_kana, :with => System::KATAKANA_PATTERN
  validates_format_of :corp_name_kana, :with => System::KATAKANA_PATTERN

  validates_presence_of :zipcode01, :zipcode02
  validates_numericality_of :zipcode01, :zipcode02
  validates_length_of :zipcode01, :maximum => 3
  validates_length_of :zipcode02, :maximum => 4

  validates_presence_of :prefecture_id,:address_city, :address_details
  validates_length_of :address_city, :address_details, :maximum => 50
  validates_inclusion_of :prefecture_id, :in => 1..47,:message => "を選択してください"

  validates_length_of :businesstime, :maximum => 50

  validates_presence_of :mail_faq,:mail_sender,:mail_admin
  validates_length_of :mail_faq,:mail_sender,:mail_admin, :maximum => 50, :allow_blank => true

  validates_length_of :trade_item,:introduction, :maximum => 99999

  validates_length_of :tel01,:tel02,:tel03, :fax01,:fax02, :fax03, :maximum => 6, :allow_blank => true


  def validate_on_create
    errors.add "","複数のデータは登録できません。"  if Shop.count > 0
  end

  def validate
    if self.tel01.size > 0
      unless  self.tel01 =~ /^(\d+)$/
        errors.add(:tel01, "を正しく入力してください")
      end
    end
    if self.tel02.size > 0
      unless  self.tel02 =~ /^(\d+)$/
        errors.add(:tel02, "を正しく入力してください")
      end
    end
    if self.tel03.size > 0
      unless  self.tel03 =~ /^(\d+)$/
        errors.add(:tel03, "を正しく入力してください")
      end
    end
    if self.fax01.size > 0
      unless  self.fax01 =~ /^(\d+)$/
        errors.add(:fax01, "を正しく入力してください")
      end
    end
    if self.fax02.size > 0
      unless  self.fax02 =~ /^(\d+)$/
        errors.add(:fax02, "を正しく入力してください")
      end
    end
    if self.fax03.size > 0
      unless  self.fax03 =~ /^(\d+)$/
        errors.add(:fax03, "を正しく入力してください")
      end
    end
  end

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
    prefecture.try(:name) + address_city + address_details
  end
end
