# -*- coding: utf-8 -*-
class CreateProductSetStyles < ActiveRecord::Migration
  def self.up
    create_table :product_set_styles do |t|
      t.column :quantity, :integer, :comment => '個数'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :product_style_id, :integer, :comment => '商品ID'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :campaign_id, :integer, :comment => 'キャンペーンID'
      t.column :aff_id, :string, :comment => 'アフィリエイトID'
    end
    add_index :product_set_styles, :deleted_at
  end

  def self.down
    remove_index :product_set_styles, :deleted_at
    drop_table :product_set_styles
  end
end
