# -*- coding: utf-8 -*-
class CreateDeliveryFees < ActiveRecord::Migration
  def self.up
    create_table :delivery_fees do |t|
      t.column :price, :integer, :comment => "価格"
      t.column :delivery_trader_id, :integer, :comment => "配送業者ID"
      t.column :prefecture_id, :integer, :comment => "都道府県ID"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :delivery_fees, :deleted_at
    add_index :delivery_fees, :delivery_trader_id
    add_index :delivery_fees, :prefecture_id
  end

  def self.down
    remove_index :delivery_fees, :prefecture_id
    remove_index :delivery_fees, :delivery_trader_id
    remove_index :delivery_fees, :deleted_at
    drop_table :delivery_fees
  end
end
