# -*- coding: utf-8 -*-
class CreateRecallDetails < ActiveRecord::Migration
  def self.up
    create_table :recall_details do |t|
      t.column :recall_id,        :integer,  :comment => '返品ID'
      t.column :order_detail_id,  :integer,  :comment => '配達要望詳細ID'
      t.column :status,           :integer,  :comment => 'ステータス'
      t.column :reason,           :integer,  :comment => '返品理由'
      t.column :quantity,         :integer,  :comment => '返品個数'
      t.column :price,            :integer,  :comment => '返品金額'
      t.column :note,             :text,     :comment => '備考'
      t.column :recalled_at,      :datetime, :comment => '返品日'
      t.column :completed_at,     :datetime, :comment => '返品完了日'
      t.column :created_at,       :datetime, :comment => '作成日'
      t.column :updated_at,       :datetime, :comment => '更新日'
      t.column :deleted_at,       :datetime, :comment => '削除日'
    end
  end

  def self.down
    drop_table :recall_details
  end
end
