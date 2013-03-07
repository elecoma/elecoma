# -*- coding: utf-8 -*-
class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :name, :string, :comment => '商品名'
      t.column :permit, :boolean, :comment => '公開設定'
      t.column :no_limit_flag, :boolean, :comment => '購入制限無し'
      t.column :url, :text, :comment => '参照URL'
      t.column :introduction, :text, :comment => '一覧コメント'
      t.column :description, :text, :comment => '詳細コメント'
      t.column :key_word, :text, :comment => '検索ワード'
      t.column :style_id, :integer, :comment => '規格ID'
      t.column :price, :integer, :comment => '価格'
      t.column :small_resource_id, :integer, :comment => '画像（小）リソースID'
      t.column :medium_resource_id, :integer, :comment => '画像（中）リソースID'
      t.column :large_resource_id, :integer, :comment => '画像（大）リソースID'
      t.column :sell_limit, :integer, :comment => '購入制限'
      t.column :point_granted_rate, :integer, :comment => 'ポイント付与率'
      t.column :category_id, :integer, :comment => '商品カテゴリーID'
      t.column :size_txt, :text, :comment => 'サイズ'
      t.column :material, :text, :comment => '素材'
      t.column :origin_country, :text, :comment => '原産国'
      t.column :weight, :text, :comment => '重さ'
      t.column :arrival_date, :text, :comment => '入荷日'
      t.column :other, :text, :comment => 'その他'
      t.column :small_resource_comment, :text, :comment => '画像（小）コメント'
      t.column :medium_resource_comment, :text, :comment => '画像（中）コメント'
      t.column :large_resource_comment, :text, :comment => '画像（大）コメント'
      t.column :free_comment, :text, :comment => 'フリー入力'
      t.column :delivery_dates, :integer, :comment => '配送日'
      t.column :have_product_style, :boolean, :comment => '商品規格フラグ'
      t.column :sale_start_at, :datetime, :comment => '販売開始日'
      t.column :sale_end_at, :datetime, :comment => '販売終了日'
      t.column :public_start_at, :datetime, :comment => '公開開始日'
      t.column :public_end_at, :datetime, :comment => '公開終了日'
      t.column :arrival_expected_date, :datetime, :comment => '入荷予定日'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :products, :deleted_at
    add_index :products, :small_resource_id
    add_index :products, :medium_resource_id
    add_index :products, :large_resource_id
    add_index :products, :style_id
  end

  def self.down
    remove_index :products, :small_resource_id
    remove_index :products, :medium_resource_id
    remove_index :products, :large_resource_id
    remove_index :products, :style_id
    remove_index :products, :deleted_at
    drop_table :products
  end
end
