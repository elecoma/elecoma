class Law < ActiveRecord::Base

  acts_as_paranoid

  TEXT_MAXLENGTH = 200

  RENDER_TYPE_TEXT = 0
  RENDER_TYPE_HTML = 1

  belongs_to :prefecture

  validates_presence_of :company,:manager,:zipcode01, :zipcode02,
                      :prefecture_id,:address_city,:address_detail,
                      :tel01,:tel02,:tel03,:email,:url,
                      :necessary_charge,:order_method,:payment_method,:payment_time_limit,:delivery_time,:return_exchange,
                      :necessary_charge_mobile,:order_method_mobile,:payment_method_mobile,:payment_time_limit_mobile,:delivery_time_mobile,:return_exchange_mobile,
                      :retailer_id,:render_type
                      

  validates_length_of :company,:manager,:address_city,:address_detail,:email,:url, :maximum => 50

  validates_length_of :tel01,:tel02,:tel03,:fax01,:fax02,:fax03 , :maximum => 6

  validates_numericality_of :zipcode01, :zipcode02,:tel01,:tel02,:tel03,:fax01,:fax02,:fax03, :allow_blank => true

  validates_length_of :zipcode01, :is => 3
  validates_length_of :zipcode02, :is => 4

  validates_inclusion_of :prefecture_id, :in => 1..47,:message => "を選択してください"

  validates_length_of :necessary_charge,:order_method,:payment_method,:payment_time_limit,:delivery_time,:return_exchange, :maximum => TEXT_MAXLENGTH
  validates_length_of :necessary_charge_mobile,:order_method_mobile,:payment_method_mobile,:payment_time_limit_mobile,:delivery_time_mobile,:return_exchange_mobile, :maximum => TEXT_MAXLENGTH

  validates_format_of :url, :with=>%r{^(https?://.*|)$}, :message=>"が不正です"

  validates_inclusion_of :render_type, :in => 0..1, :message => "を選択してください"

#  def validate_on_create
#    errors.add "","複数のデータは登録できません。"  if Law.count > 0
#  end

  # 表示系のメソッド
  def zipcode
    "#{zipcode01}-#{zipcode02}" 
  end

  def address
    prefecture ? prefecture.name + address_city + address_detail : ""
  end

  def tel 
    "#{tel01}-#{tel02}-#{tel03}"
  end
  
  def fax 
    "#{fax01}-#{fax02}-#{fax03}"
  end

  def html?
    return render_type == RENDER_TYPE_HTML
  end

end
