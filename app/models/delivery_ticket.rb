class DeliveryTicket < ActiveRecord::Base

  belongs_to :order_delivery

  validates_presence_of :order_delivery_id
  validates_presence_of :code
end
