# -*- coding: utf-8 -*-
class CreateResourceDatas < ActiveRecord::Migration
  def self.up
    create_table :resource_datas do |t|
      t.column :content, :binary, :comment => 'バイナリデータ'
      t.column :resource_id, :integer, :comment => 'リソースID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :resource_datas, :resource_id
  end

  def self.down
    remove_index :resource_datas, :resource_id
    drop_table :resource_datas
  end
end
