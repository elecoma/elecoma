class DeliveryAddress < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :customer
  belongs_to :prefecture

  attr_accessor :target_columns

  # 追加お届け先の最大所持件数
  MAXIMUM_POSITION = 20

  validates_presence_of :family_name, :first_name, :family_name_kana, :first_name_kana,
                        :zipcode01, :zipcode02, :tel01, :tel02, :tel03,
                        :prefecture_id, :address_city, :address_detail
  validates_numericality_of :zipcode01, :zipcode02, :prefecture_id,
                            :tel01, :tel02, :tel03, :allow_blank => true
  validates_length_of :zipcode01, :is => 3, :allow_blank => true
  validates_length_of :zipcode02, :is => 4, :allow_blank => true
  validates_format_of :family_name_kana, :with => System::KATAKANA_PATTERN
  validates_format_of :first_name_kana, :with => System::KATAKANA_PATTERN

  def validate
    strip_errors
  end

  def strip_errors
    # 対象のカラム以外のエラーは無視する
    return if target_columns.nil?
    e = errors.select{|k,_|target_columns.include?(k)}
    errors.clear
    e.each do |k,v|
      errors.add k, v
    end
  end

  # 郵便番号から住所を取ってくる
  def update_address!(overwrite=true)
    return if zipcode01.blank? or zipcode02.blank?
    if overwrite || (prefecture_id.blank? && address_city.blank? && address_detail.blank?)
      zip = Zip.find_by_zipcode(zipcode01, zipcode02)
      if zip
        self.prefecture_id = zip.prefecture_id
        self.address_city = zip.address_city
        self.address_detail = zip.address_details
      end
    end
  end

end
