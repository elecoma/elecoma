# -*- coding: utf-8 -*-
class CreatePaymentPlugins < ActiveRecord::Migration
  def self.up
    create_table :payment_plugins do |t|
      t.column :name, :string, :comment => "プラグイン名"
      t.column :model_name, :string, :comment => "モデル名"
      t.column :detail, :text, :comment => "詳細"
      t.column :enable, :boolean, :default => false, :comment => "有効/無効"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
  end

  def self.down
    drop_table :payment_plugins
  end
end
