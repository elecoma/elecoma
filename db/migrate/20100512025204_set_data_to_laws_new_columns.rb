class SetDataToLawsNewColumns < ActiveRecord::Migration
  def self.up
    law = Law.first
    law.retailer_id = Retailer::DEFAULT_ID
    law.necessary_charge_mobile = law.necessary_charge
    law.order_method_mobile = law.order_method
    law.payment_method_mobile = law.payment_method
    law.payment_time_limit_mobile = law.payment_time_limit
    law.delivery_time_mobile = law.delivery_time
    law.return_exchange_mobile = law.return_exchange
    law.render_type = 0
    law.save!
  end

  def self.down
  end
end
