class DeliveryTime < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :delivery_trader
  has_many :orders
  
  MAX_SIZE = 16
end
