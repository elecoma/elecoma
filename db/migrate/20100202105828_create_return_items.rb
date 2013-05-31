# -*- coding: utf-8 -*-
class CreateReturnItems < ActiveRecord::Migration
  def self.up
    create_table :return_items do |t|
      t.column :admin_user_id ,:integer,:comment =>'登録更新者ID'
      t.column :product_id , :integer,:comment =>'商品ID'
      t.column :product_style_id , :integer,:comment =>'商品規格ID'
      t.column :returned_at ,:datetime, :comment =>'返品日時'
      t.column :returned_count ,:integer,:comment =>'返品数'
      t.column :comment ,:text,:comment =>'返品理由コメント'  
      t.column :deleted_at ,:datetime, :comment =>'削除日'
      t.timestamps
    end
  end

  def self.down
    drop_table :return_items
  end
end
