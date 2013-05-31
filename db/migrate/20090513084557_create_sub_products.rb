# -*- coding: utf-8 -*-
class CreateSubProducts < ActiveRecord::Migration
  def self.up
    create_table :sub_products do |t|
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :medium_resource_id, :integer, :comment => '商品（中）ID'
      t.column :large_resource_id, :integer, :comment => '商品（大）ID'
      t.column :name, :string, :comment => '名前'
      t.column :description, :text, :comment => 'コメント'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :no, :integer, :comment => '番号'
    end
    add_index :sub_products, :deleted_at
    add_index :sub_products, :large_resource_id
    add_index :sub_products, :medium_resource_id
    add_index :sub_products, :product_id
  end

  def self.down
    remove_index :sub_products, :product_id
    remove_index :sub_products, :medium_resource_id
    remove_index :sub_products, :large_resource_id
    remove_index :sub_products, :deleted_at
    drop_table :sub_products
  end
end
