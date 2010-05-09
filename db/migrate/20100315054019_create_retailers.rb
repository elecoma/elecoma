# -*- coding: utf-8 -*-
class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers, :comment => '販売元テーブル' do |t|
      t.column :name, :string, :comment => '販売元名称'
      t.column :name_kana, :string, :comment => '販売元名称（カナ）'
      t.column :corp_name, :string, :comment => '会社名'
      t.column :corp_name_kana, :string, :comment => '会社名（カナ）'
      t.column :deleted_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :retailers
  end
end
