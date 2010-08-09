class AddRetailerIfDontHaveRetailer < ActiveRecord::Migration
  def self.up
    begin
      r = Retailer.find(1)
    rescue ActiveRecord::RecordNotFound
      r = Retailer.new
      r.id = 1
      r.name = "メイン販売元"
      r.save!
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.down
  end
end
