class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.column :customer_id,  :integer,   :comment => '顧客ID'
      t.column :code,         :string,    :comment => '受注番号'
      t.column :received_at,  :datetime,  :comment => '受注日'
      t.column :created_at,   :datetime,  :comment => '作成日'
      t.column :updated_at,   :datetime,  :comment => '更新日'
      t.column :deleted_at,   :datetime,  :comment => '削除日'
    end
    add_index :orders, :deleted_at
    add_index :orders, :customer_id
  end

  def self.down
    remove_index :orders, :customer_id
    remove_index :orders, :deleted_at
    drop_table :orders
  end
end
