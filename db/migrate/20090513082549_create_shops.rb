# -*- coding: utf-8 -*-
class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.column :name, :string, :comment => '店名'
      t.column :name_kana, :string, :comment => '店名（カナ）'
      t.column :corp_name, :string, :comment => '会社名'
      t.column :corp_name_kana, :string, :comment => '会社名（カナ）'
      t.column :zipcode01, :string, :comment => '郵便番号（前半）'
      t.column :zipcode02, :string, :comment => '郵便番号（後半）'
      t.column :address_city, :string, :comment => '住所（市区町村）'
      t.column :address_details, :string, :comment => '住所（詳細）'
      t.column :tel01, :string, :comment => '電話番号１'
      t.column :tel02, :string, :comment => '電話番号２'
      t.column :tel03, :string, :comment => '電話番号３'
      t.column :fax01, :string, :comment => 'FAX番号１'
      t.column :fax02, :string, :comment => 'FAX番号２'
      t.column :fax03, :string, :comment => 'FAX番号３'
      t.column :businesstime, :string, :comment => '店舗営業時間'
      t.column :mail_shop, :string, :comment => '注文受付メールアドレス'
      t.column :mail_faq, :string, :comment => '問合受付メールアドレス'
      t.column :mail_sender, :string, :comment => 'メール送信元メールアドレス'
      t.column :mail_admin, :string, :comment => '管理者メール'
      t.column :trade_item, :text, :comment => '取扱商品'
      t.column :introduction, :text, :comment => '店舗案内'
      t.column :prefecture_id, :integer, :comment => '都道府県ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :shops, :deleted_at
    add_index :shops, :prefecture_id
  end

  def self.down
    remove_index :shops, :prefecture_id
    remove_index :shops, :deleted_at
    drop_table :shops
  end
end
