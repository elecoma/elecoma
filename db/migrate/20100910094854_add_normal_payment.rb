# -*- coding: utf-8 -*-
class AddNormalPayment < ActiveRecord::Migration
  def self.up
    plugin = PaymentPlugin.new
    plugin.name = "通常支払プラグイン"
    plugin.model_name = "NormalPaymentPlugin"
    plugin.detail = "通常支払に使うプラグインで、なにもせずにそのまま受注データを作成します。"
    plugin.enable = true
    plugin.save
    execute("UPDATE payments SET payment_plugin_id = #{plugin.id}")
  end

  def self.down
    plugin = PaymentPlugin.find_by_model_name("NormalPaymentPlugin")
    plugin.destroy if plugin
  end
end
