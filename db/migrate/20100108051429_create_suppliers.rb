# -*- coding: utf-8 -*-
class CreateSuppliers < ActiveRecord::Migration
  def self.up
    create_table :suppliers do |t|
      t.column :name,         :string,  :comment => '仕入先名'
      t.column :zipcode01,    :string, :comment => "郵便番号(前半)"
      t.column :zipcode02,    :string, :comment => "郵便番号(後半)"
      t.column :prefecture_id,  :integer, :comment => "都道府県ID"
      t.column :address_city,   :string, :comment => "住所(市町村)"
      t.column :address_detail, :string, :comment => "住所(詳細)"
      t.column :tel01, :string, :comment => "電話番号1"
      t.column :tel02, :string, :comment => "電話番号2"
      t.column :tel03, :string, :comment => "電話番号3"
      t.column :fax01, :string, :comment => "FAX番号1"
      t.column :fax02, :string, :comment => "FAX番号2"
      t.column :fax03, :string, :comment => "FAX番号3"
      t.column :contact_name,   :string,  :comment => '仕入先担当者名'
      t.column :email, :string, :comment => "メールアドレス"
      t.column :percentage,     :integer,  :comment => "商品掛け率"
      t.column :tax_rule,     :integer,  :comment => "税額端数処理"
      t.column :free_comment,   :text,  :comment => "備考"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :suppliers, :deleted_at
    add_index :suppliers, :name
  end

  def self.down
    remove_index :suppliers, :deleted_at
    remove_index :suppliers, :name
    drop_table :suppliers
  end
end
