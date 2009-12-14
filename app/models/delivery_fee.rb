class DeliveryFee < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :delivery_trader
  belongs_to :prefecture
  MAX_SIZE = 48

  validates_presence_of :price

  def prefecture_name
    if prefecture
      prefecture.name
    else
      '離島'
    end
  end

end
