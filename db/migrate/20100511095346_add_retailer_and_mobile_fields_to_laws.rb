class AddRetailerAndMobileFieldsToLaws < ActiveRecord::Migration
  def self.up
    add_column :laws, :render_type, :integer, :default => 0, :comment => "表示タイプ(0:text, 1:html)"
    add_column :laws, :retailer_id, :integer, :comment => "販売元ID"
    add_column :laws, :necessary_charge_mobile, :text, :comment => "商品代金以外の必要料金(モバイル)"
    add_column :laws, :order_method_mobile, :text, :comment => "注文方法(モバイル)"
    add_column :laws, :payment_method_mobile, :text, :comment => "支払方法(モバイル)"
    add_column :laws, :payment_time_limit_mobile, :text, :comment => "支払期限(モバイル)"
    add_column :laws, :delivery_time_mobile, :text, :comment => "引き渡し時期(モバイル)"
    add_column :laws, :return_exchange_mobile, :text, :comment => "返品・交換について(モバイル)"
  end

  def self.down
    remove_column :laws, :return_exchange_mobile
    remove_column :laws, :delivery_time_mobile
    remove_column :laws, :payment_time_limit_mobile
    remove_column :laws, :payment_method_mobile
    remove_column :laws, :order_method_mobile
    remove_column :laws, :necessary_charge_mobile
    remove_column :laws, :retailer_id
    remove_column :laws, :render_type
  end
end
