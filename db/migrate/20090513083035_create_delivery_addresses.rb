# -*- coding: utf-8 -*-
class CreateDeliveryAddresses < ActiveRecord::Migration
  def self.up
    create_table :delivery_addresses do |t|
      t.column :customer_id, :integer, :comment => "顧客ID"
      t.column :prefecture_id, :integer, :comment => "都道府県ID"
      t.column :zipcode01, :string, :comment => "郵便番号(前半)"
      t.column :zipcode02, :string, :comment => "郵便番号(後半)"
      t.column :tel01, :string, :comment => "電話番号1"
      t.column :tel02, :string, :comment => "電話番号2"
      t.column :tel03, :string, :comment => "電話番号3"
      t.column :position, :integer, :comment => "順番"
      t.column :family_name, :string, :comment => "姓"
      t.column :first_name, :string, :comment => "名"
      t.column :family_name_kana, :string, :comment => "姓(カナ)"
      t.column :first_name_kana, :string, :comment => "名(カナ)"
      t.column :address_city, :string, :comment => "住所(市区町村)"
      t.column :address_detail, :string, :comment => "住所(詳細)"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :delivery_addresses, :customer_id
    add_index :delivery_addresses, :deleted_at
    add_index :delivery_addresses, :position
    add_index :delivery_addresses, :prefecture_id
  end

  def self.down
    remove_index :delivery_addresses, :prefecture_id
    remove_index :delivery_addresses, :position
    remove_index :delivery_addresses, :deleted_at
    remove_index :delivery_addresses, :customer_id
    drop_table :delivery_addresses
  end
end
