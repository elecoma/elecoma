# -*- coding: utf-8 -*-
class AddPaymentPluginIdToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :payment_plugin_id, :integer, :comment => "支払いプラグインID"
  end

  def self.down
    remove_column :payments, :payment_plugin_id
  end
end
