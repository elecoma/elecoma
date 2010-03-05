# -*- coding: utf-8 -*-
class CreateFunctions < ActiveRecord::Migration
  def self.up
    create_table :functions do |t|
      t.column :name, :string, :comment => '機能名'
      t.column :code, :string, :comment => '機能コード'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :functions, :deleted_at
    add_index :functions, :position
  end

  def self.down
    remove_index :functions, :position
    remove_index :functions, :deleted_at
    drop_table :functions
  end
end
