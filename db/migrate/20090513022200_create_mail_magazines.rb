# -*- coding: utf-8 -*-
class CreateMailMagazines < ActiveRecord::Migration
  def self.up
    create_table :mail_magazines do |t|
      t.column :subject,        :string,    :comment => '件名'
      t.column :body,           :text,      :comment => '本文'
      t.column :condition,      :text,      :comment => '配信条件'
      t.column :schedule_case,  :integer,   :comment => '配信予定件数'
      t.column :delivered_case, :integer,   :comment => '配信件数'
      t.column :sent_start_at,  :datetime,  :comment => '配信開始時刻'
      t.column :sent_end_at,    :datetime,  :comment => '配信終了時刻'
      t.column :created_at,     :datetime,  :comment => '作成日'
      t.column :updated_at,     :datetime,  :comment => '更新日'
      t.column :deleted_at,     :datetime,  :comment => '削除日'
    end
    add_index :mail_magazines, :deleted_at
  end

  def self.down
    remove_index :mail_magazines, :deleted_at
    drop_table :mail_magazines
  end
end
