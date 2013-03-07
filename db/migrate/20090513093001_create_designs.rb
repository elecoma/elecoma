# -*- coding: utf-8 -*-
class CreateDesigns < ActiveRecord::Migration
  def self.up
    create_table :designs do |t|
      t.column :pc1,       :text,     :comment => "PCフリースペース1"
      t.column :pc2,       :text,     :comment => "PCフリースペース2"
      t.column :mobile1,       :text,     :comment => "MOBILEフリースペース"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :designs, :deleted_at
  end

  def self.down
    remove_index :designs, :deleted_at
    drop_table :designs
  end
end
