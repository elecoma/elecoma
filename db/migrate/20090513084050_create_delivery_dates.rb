class CreateDeliveryDates < ActiveRecord::Migration
  def self.up
    create_table :delivery_dates do |t|
      t.column :product_id, :integer, :comment => "商品ID"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :delivery_dates, :deleted_at
    add_index :delivery_dates, :product_id
  end

  def self.down
    remove_index :delivery_dates, :product_id
    remove_index :delivery_dates, :deleted_at
    drop_table :delivery_dates
  end
end
