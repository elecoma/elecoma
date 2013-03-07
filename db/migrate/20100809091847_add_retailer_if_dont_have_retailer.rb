# -*- coding: utf-8 -*-
class AddRetailerIfDontHaveRetailer < ActiveRecord::Migration
  def self.up
    begin
      r = Retailer.find(1)
    rescue ActiveRecord::RecordNotFound
      r = Retailer.new
      r.name = "メイン販売元"
      r.save!
      if r.id != 1
        r.id = 1
        r.save!
      end
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.down
  end
end
