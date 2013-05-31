# -*- coding: utf-8 -*-
class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :name, :string, :comment => "カテゴリ名"
      t.column :parent_id, :integer, :comment => "親カテゴリID"
      t.column :position, :integer, :comment => "順番"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
      t.column :code, :string, :comment => "商品コード"
      t.column :parent_code, :string, :comment => "親カテゴリの商品コード"
      t.column :children_ids, :string, :comment => "子カテゴリID"
      t.column :resource_id, :integer, :comment => "画像ID"
      t.column :menu_resource_id, :integer, :comment => "メニュー画像ID"
      t.column :free_space, :text, :comment => "メニュー画像ID"
    end
    add_index :categories, :deleted_at
    add_index :categories, :parent_id
  end

  def self.down
    remove_index :categories, :parent_id
    remove_index :categories, :deleted_at
    drop_table :categories
  end
end
