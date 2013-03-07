# -*- coding: utf-8 -*-
class CreateNewInformations < ActiveRecord::Migration
  def self.up
    create_table :new_informations do |t|
      t.column :date,         :timestamp, :comment => '表示日付'
      t.column :name,         :string,    :comment => 'タイトル'
      t.column :url,          :string,    :comment => 'URL'
      t.column :body,         :text,      :comment => '本文'
      t.column :new_window,   :boolean,   :comment => '別ウィンドウで開く'
      t.column :position,     :integer,   :comment => '順番'
      t.column :created_at,   :datetime,  :comment => '作成日'
      t.column :updated_at,   :datetime,  :comment => '更新日'
      t.column :deleted_at,   :datetime,  :comment => '削除日'
    end
    add_index :new_informations, :deleted_at
    add_index :new_informations, :position
  end

  def self.down
    remove_index :new_informations, :position
    remove_index :new_informations, :deleted_at
    drop_table :new_informations
  end
end
