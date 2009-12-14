class CreateStockTables < ActiveRecord::Migration
  def self.up
    create_table :stock_tables do |t|
      t.column :target_date, :datetime, :comment => 'データ出力日'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :count_fixed, :boolean, :comment => 'バッチ/再作成'
    end
    add_index :stock_tables, :deleted_at
  end

  def self.down
    remove_index :stock_tables, :deleted_at
    drop_table :stock_tables
  end
end
