class Supplier < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :prefecture
  has_many :products
  #DEFAULT_IDは仕入先不使用時のIDとして定義
  #id=1のデータは編集不可、削除不可
  DEFAULT_SUPPLIER_ID = 1
  SHISYAGONYU, KIRISUTE, KIRIAGE = 0, 1, 2
  TAX_RULE_NAMES = { SHISYAGONYU => "四捨五入", KIRISUTE => "切り捨て", KIRIAGE => "切り上げ"}  
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 50

  validates_presence_of :zipcode01, :zipcode02
  validates_numericality_of :zipcode01, :zipcode02, :allow_blank=>true
  validates_length_of :zipcode01, :is => 3, :allow_blank=>true
  validates_length_of :zipcode02, :is => 4, :allow_blank=>true
  validates_associated :prefecture
  validates_presence_of :prefecture_id,:address_city, :address_detail
  validates_length_of :address_city, :address_detail, :maximum => 100
  
  validates_presence_of :contact_name
  validates_length_of :contact_name, :maximum => 50
  
  validates_presence_of :tel01, :tel02, :tel03
  validates_numericality_of :tel01, :tel02, :tel03, :allow_blank => true
  validates_length_of :tel01, :tel02, :tel03, :maximum => 6, :allow_blank => true
  
  validates_numericality_of :fax01, :fax02, :fax03, :allow_blank => true
  validates_length_of :fax01, :fax02, :fax03, :maximum => 6, :allow_blank => true
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  
  validates_inclusion_of :percentage, :in => (0..100), :allow_blank => true
  
  validates_length_of :free_comment, :maximum => 10000 , :allow_blank => true
  validates_inclusion_of :tax_rule, :in => [SHISYAGONYU, KIRISUTE, KIRIAGE] , :allow_blank => true

  before_update :check_default
  before_destroy :check_default_and_products
  
  def validate
    super
    # FAX どれかが入力されている時だけ検証
    if not [fax01, fax02, fax03].all?(&:blank?)
      fax_items = %w(fax01 fax02 fax03)
      errors.add_on_blank fax_items, "が入力されていません"
    end
  end
  
  def tel
    "#{tel01}-#{tel02}-#{tel03}" unless tel01.blank? or tel02.blank? or tel03.blank? 
  end
  
  def fax
    "#{fax01}-#{fax02}-#{fax03}" unless fax01.blank? or fax02.blank? or fax03.blank? 
  end
  
  def prefecture_name
    prefecture && prefecture.name
  end
  
  def tax_rule_label
    TAX_RULE_NAMES[tax_rule] unless tax_rule.blank?
  end
  def check_default_and_products
    check_default
    #直接URL入力で商品を持っている仕入先を削除防止するため
    unless self.products.blank?
      raise ActiveRecord::ReadOnlyRecord
    end
  end
  def check_default
    #id=1のデータはデフォルトの状態のみで、編集不可、削除不可
    if self.id == DEFAULT_SUPPLIER_ID
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end
