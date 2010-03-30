# -*- coding: utf-8 -*-
class AddRetailerIdToManyTables < ActiveRecord::Migration
  def self.up
    add_column :products, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE products SET retailer_id = 1")
    add_column :admin_users, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE admin_users SET retailer_id = 1")
    add_column :delivery_traders, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE delivery_traders SET retailer_id = 1")
    add_column :suppliers, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE suppliers SET retailer_id = 1")
    add_column :styles, :retailer_id, :integer, :default => 1, :comment => "販売元ID"
    execute("UPDATE styles SET retailer_id = 1")
  end

  def self.down
    remove_columns :styles, :retailer_id
    remove_columns :suppliers, :retailer_id
    remove_columns :delivery_traders, :retailer_id
    remove_columns :admin_users, :retailer_id
    remove_columns :products, :retailer_id
  end
end
