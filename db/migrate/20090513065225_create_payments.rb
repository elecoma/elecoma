# -*- coding: utf-8 -*-
class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.column :name,               :string,    :comment => '名前'
      t.column :lower_limit,        :integer,    :comment => '利用条件（下限）'
      t.column :upper_limit,        :integer,   :comment => '利用条件（上限）'
      t.column :resource_id,        :integer,   :comment => '画像リソースID'
      t.column :fee,                :integer,   :comment => '手数料'
      t.column :delivery_trader_id, :integer,   :comment => '配達業者ID'
      t.column :position,           :integer,   :comment => '順番'
      t.column :created_at,         :datetime,  :comment => '作成日'
      t.column :updated_at,         :datetime,  :comment => '更新日'
      t.column :deleted_at,         :datetime,  :comment => '削除日'
    end
    add_index :payments, :deleted_at
    add_index :payments, :delivery_trader_id
    add_index :payments, :position
    add_index :payments, :resource_id
  end

  def self.down
    remove_index :payments, :position
    remove_index :payments, :resource_id
    remove_index :payments, :delivery_trader_id
    remove_index :payments, :deleted_at
    drop_table :payments
  end
end
