# -*- coding: utf-8 -*-
class CreateKiyakus < ActiveRecord::Migration
  def self.up
    create_table :kiyakus do |t|
      t.column :name, :string, :comment => '規約タイトル'
      t.column :content, :text, :comment => '規約内容'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :kiyakus, :deleted_at
    add_index :kiyakus, :position
  end

  def self.down
    remove_index :kiyakus, :position
    remove_index :kiyakus, :deleted_at
    drop_table :kiyakus
  end
end
