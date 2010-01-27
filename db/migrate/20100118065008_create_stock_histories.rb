class CreateStockHistories < ActiveRecord::Migration
  def self.up
    create_table :stock_histories do |t|
      t.column :admin_user_id ,:integer,:comment =>'登録更新者ID'
      t.column :product_id , :integer,:comment =>'商品ID'
      t.column :product_style_id , :integer,:comment =>'商品規格ID'
      t.column :moved_at ,:datetime, :comment =>'移動日時'
      t.column :storaged_count ,:integer,:comment =>'入庫数'
      t.column :orderable_count ,:integer,:comment =>'受注可能数'
      t.column :orderable_adjustment ,:integer,:comment =>'受注可能数調整数'
      t.column :actual_count ,:integer,:comment =>'実在庫数'
      t.column :actual_adjustment ,:integer,:comment =>'実在庫調整数'
      t.column :broken_count ,:integer,:comment =>'不良在庫数'
      t.column :broken_adjustment ,:integer,:comment =>'不良在庫調整数'
      t.column :comment ,:text,:comment =>'移動理由コメント'  
      t.column :stock_type ,:integer,:comment =>'作業区分（0：入庫、1：移動）'
      t.column :deleted_at ,:datetime, :comment =>'削除日'
    end
    add_index :stock_histories, :deleted_at
    add_index :stock_histories, :product_id
    add_index :stock_histories, :product_style_id  
  end

  def self.down
    remove_index :stock_histories, :deleted_at
    remove_index :stock_histories, :product_id
    remove_index :stock_histories, :product_style_id     
    drop_table :stock_histories
  end
end
