# -*- coding: utf-8 -*-
class AddRetailerIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE orders SET retailer_id = 1")
  end

  def self.down
    remove_columns :orders, :retailer_id
  end
end
