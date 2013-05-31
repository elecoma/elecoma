# -*- coding: utf-8 -*-
class CreateProductStyles < ActiveRecord::Migration
  def self.up
    create_table :product_styles do |t|
      t.column :name,               :string,    :comment => '商品名'
      t.column :product_id,         :integer,   :comment => '商品ID'
      t.column :code,               :string,    :comment => '商品コード'
      t.column :style_category_id1, :integer,   :comment => '規格カテゴリー1'
      t.column :style_category_id2, :integer,   :comment => '規格カテゴリー2'
      t.column :position,           :integer,   :comment => '順番'
      t.column :actual_count,       :integer,   :comment => '実在個数'
      t.column :purchased_count,    :integer,   :comment => '発注済み数'
      t.column :scheduled_count,    :integer,   :comment => '発注予定数'
      t.column :orderable_count,    :integer,   :comment => '受注可能数'
      t.column :broken_count,        :integer,   :comment => '不良在庫数'
      t.column :sell_price,         :integer,   :comment => '価格'
      t.column :sale_start_at,      :datetime,  :comment => '販売開始日'
      t.column :sale_end_at,        :datetime,  :comment => '販売終了日'
      t.column :created_at,         :datetime,  :comment => '作成日'
      t.column :updated_at,         :datetime,  :comment => '更新日'
      t.column :deleted_at,         :datetime,  :comment => '削除日'
    end
    add_index :product_styles, :deleted_at
    add_index :product_styles, :position
    add_index :product_styles, :product_id
  end

  def self.down
    remove_index :product_styles, :position
    remove_index :product_styles, :product_id
    remove_index :product_styles, :deleted_at
    drop_table :product_styles
  end
end
