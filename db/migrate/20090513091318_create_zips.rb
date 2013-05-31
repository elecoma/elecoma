# -*- coding: utf-8 -*-
class CreateZips < ActiveRecord::Migration
  def self.up
    create_table :zips do |t|
      t.column :zipcode01, :string, :limit => 3, :comment => '郵便番号（前半）'
      t.column :zipcode02, :string, :limit => 4, :comment => '郵便番号（後半）'
      t.column :prefecture_name, :string, :comment => '都道府県名'
      t.column :address_city, :string, :comment => '住所（市区町村）'
      t.column :address_details, :string, :comment => '住所（詳細）'
      t.column :prefecture_id, :integer, :comment => '都道府県ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :isolation_type, :integer, :comment => '離島タイプ'
      t.column :can_daibiki, :boolean, :comment => '代引きフラグ'
    end
    add_index :zips, :deleted_at
    add_index :zips, :prefecture_id
    add_index :zips, [:zipcode01, :zipcode02], :unique => false
  end

  def self.down
    remove_index :zips, :column => [:zipcode01, :zipcode02]
    remove_index :zips, :prefecture_id
    remove_index :zips, :deleted_at
    drop_table :zips
  end
end
