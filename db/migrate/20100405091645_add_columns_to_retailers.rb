# -*- coding: utf-8 -*-
class AddColumnsToRetailers < ActiveRecord::Migration
  def self.up
    add_column :retailers, :zipcode01, :string, :comment => '郵便番号（前半）'
    add_column :retailers, :zipcode02, :string, :comment => '郵便番号（後半）'
    add_column :retailers, :address_city, :string, :comment => '住所（市区町村）'
    add_column :retailers, :address_details, :string, :comment => '住所（詳細）'
    add_column :retailers, :tel01, :string, :comment => '電話番号１'
    add_column :retailers, :tel02, :string, :comment => '電話番号２'
    add_column :retailers, :tel03, :string, :comment => '電話番号３'
    add_column :retailers, :fax01, :string, :comment => 'FAX番号１'
    add_column :retailers, :fax02, :string, :comment => 'FAX番号２'
    add_column :retailers, :fax03, :string, :comment => 'FAX番号３'
    add_column :retailers, :businesstime, :string, :comment => '店舗営業時間'
    add_column :retailers, :mail_shop, :string, :comment => '注文受付メールアドレス'
    add_column :retailers, :mail_faq, :string, :comment => '問合受付メールアドレス'
    add_column :retailers, :mail_sender, :string, :comment => 'メール送信元メールアドレス'
    add_column :retailers, :mail_admin, :string, :comment => '管理者メール'
    add_column :retailers, :trade_item, :text, :comment => '取扱商品'
    add_column :retailers, :introduction, :text, :comment => '店舗案内'
    add_column :retailers, :prefecture_id, :integer, :comment => '都道府県ID'
    add_column :retailers, :resource_id, :integer, :comment => "画像ID"
    add_column :retailers, :menu_resource_id, :integer, :comment => "メニュー画像ID"
    r = Retailer.new
    s = Shop.find(:first)
    unless s.nil?
      r.name = s.name
      r.name_kana = s.name_kana
      r.corp_name = s.corp_name
      r.corp_name_kana = s.corp_name_kana
      r.save
    end
  end

  def self.down
    remove_column :retailers, :zipcode01
    remove_column :retailers, :zipcode02
    remove_column :retailers, :address_city
    remove_column :retailers, :address_details
    remove_column :retailers, :tel01
    remove_column :retailers, :tel02
    remove_column :retailers, :tel03
    remove_column :retailers, :fax01
    remove_column :retailers, :fax02
    remove_column :retailers, :fax03
    remove_column :retailers, :businesstime
    remove_column :retailers, :mail_shop
    remove_column :retailers, :mail_faq
    remove_column :retailers, :mail_sender
    remove_column :retailers, :mail_admin
    remove_column :retailers, :trade_item
    remove_column :retailers, :introduction
    remove_column :retailers, :prefecture_id
    remove_column :retailers, :resource_id
    remove_column :retailers, :menu_resource_id
  end
end
