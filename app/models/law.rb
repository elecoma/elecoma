class Law < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :prefecture

  validates_presence_of :company,:manager,:zipcode01, :zipcode02,
                      :prefecture_id,:address_city,:address_detail,
                      :tel01,:tel02,:tel03,:email,:url,
                      :necessary_charge,:order_method,:payment_method,:payment_time_limit,:delivery_time,:return_exchange

  validates_length_of :company,:manager,:address_city,:address_detail,:email,:url, :maximum => 50

  validates_length_of :tel01,:tel02,:tel03,:fax01,:fax02,:fax03 , :maximum => 4

  validates_numericality_of :zipcode01, :zipcode02,:tel01,:tel02,:tel03,:fax01,:fax02,:fax03, :allow_blank => true

  validates_length_of :zipcode01, :is => 3
  validates_length_of :zipcode02, :is => 4

  validates_inclusion_of :prefecture_id, :in => 1..47,:message => "を選択してください"

  validates_length_of :necessary_charge,:order_method,:payment_method,:payment_time_limit,:delivery_time,:return_exchange , :maximum => 200

  validates_format_of :url, :with=>%r{^(https?://.*|)$}, :message=>"が不正です"

  def validate_on_create
    errors.add "","複数のデータは登録できません。"  if Law.count > 0
  end

  # 表示系のメソッド
  def zipcode
    "#{zipcode01}-#{zipcode02}" 
  end

  def address
    prefecture.name + address_city + address_detail
  end

  def tel 
    "#{tel01}-#{tel02}-#{tel03}"
  end
  
  def fax 
    "#{fax01}-#{fax02}-#{fax03}"
  end
end
