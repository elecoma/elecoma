# -*- coding: utf-8 -*-
class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.column :name, :string, :comment => 'ファイル名'
      t.column :size, :integer, :comment => '画像サイズ'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :content_type, :string, :comment => 'コンテンツタイプ'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :resources, :deleted_at
  end

  def self.down
    remove_index :resources, :deleted_at
    drop_table :resources
  end
end
