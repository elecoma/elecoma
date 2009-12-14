class CreateProductAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :product_access_logs do |t|
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :session_id, :string, :comment => 'セッションID'
      t.column :customer_id, :integer, :comment => '顧客ID'
      t.column :docomo_flg, :boolean, :comment => 'ドコモフラグ'
      t.column :send_flg, :boolean, :comment => '送信フラグ'
      t.column :complete_flg, :boolean, :comment => '完了フラグ'
      t.column :ident, :string, :comment => '固有アクセス識別'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :product_access_logs, :deleted_at
  end

  def self.down
    remove_index :product_access_logs, :deleted_at
    drop_table :product_access_logs
  end
end
