# -*- coding: utf-8 -*-
class CreatePrivacies < ActiveRecord::Migration
  def self.up
    create_table :privacies do |t|
      t.column :content, :string, :comment => '本文'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :privacies, :deleted_at
  end

  def self.down
    remove_index :privacies, :deleted_at
    drop_table :privacies
  end
end
