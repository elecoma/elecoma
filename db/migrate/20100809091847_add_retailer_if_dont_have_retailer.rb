class AddRetailerIfDontHaveRetailer < ActiveRecord::Migration
  def self.up
    r = Retailer.find(1)
    unless r
      r = Retailer.new
      r.id = 1
      r.name = "メイン販売元"
      r.save!
    end
  end

  def self.down
  end
end
