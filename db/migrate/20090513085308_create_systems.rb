# -*- coding: utf-8 -*-
class CreateSystems < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
      t.column :tax, :integer, :comment => '消費税率'
      t.column :tax_rule, :integer, :comment => '消費税規則'
      t.column :free_delivery_rule, :integer, :comment => '送料無料条件'
      t.column :point_rate, :integer, :comment => 'ポイント付与率'
      t.column :regist_point, :integer, :comment => '会員登録時付与ポイント'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :buying_rule, :integer, :comment => '購入規則'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :systems, :deleted_at
  end

  def self.down
    remove_index :systems, :deleted_at
    drop_table :systems
  end
end
