# -*- coding: utf-8 -*-
class CreateInquiries < ActiveRecord::Migration
  def self.up
    create_table :inquiries do |t|
      t.column :body, :text, :comment => 'お問い合わせ内容'
      t.column :email, :string, :comment => 'メールアドレス'
      t.column :name, :string, :comment => 'お問い合わせ送信者名'
      t.column :tel, :string, :comment => '電話番号'
      t.column :order_number, :string, :comment => '受注番号'
      t.column :kind, :integer, :comment => 'お問い合わせ種別'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :inquiries, :deleted_at
  end

  def self.down
    remove_index :inquiries, :deleted_at
    drop_table :inquiries
  end
end
