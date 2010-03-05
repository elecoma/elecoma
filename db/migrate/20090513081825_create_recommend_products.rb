# -*- coding: utf-8 -*-
class CreateRecommendProducts < ActiveRecord::Migration
  def self.up
    create_table :recommend_products do |t|
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :position, :integer, :comment => '順番'
      t.column :description, :text, :comment => 'オススメコメント'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :recommend_products, :deleted_at
    add_index :recommend_products, :position
    add_index :recommend_products, :product_id
  end

  def self.down
    remove_index :recommend_products, :product_id
    remove_index :recommend_products, :position
    remove_index :recommend_products, :deleted_at
    drop_table :recommend_products
  end
end
