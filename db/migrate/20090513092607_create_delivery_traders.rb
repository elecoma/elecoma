# -*- coding: utf-8 -*-
class CreateDeliveryTraders < ActiveRecord::Migration
  def self.up
    create_table :delivery_traders do |t|
      t.column :name, :string, :comment => "配送業者名"
      t.column :url, :string, :comment => "伝票No.URL"
      t.column :position, :integer, :comment => "順番"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :delivery_traders, :deleted_at
    add_index :delivery_traders, :position
  end

  def self.down
    remove_index :delivery_traders, :position
    remove_index :delivery_traders, :deleted_at
    drop_table :delivery_traders
  end
end
