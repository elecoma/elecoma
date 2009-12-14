class CreateDeliveryTimes < ActiveRecord::Migration
  def self.up
    create_table :delivery_times do |t|
      t.column :position, :integer, :comment => "順番"
      t.column :delivery_trader_id, :integer, :comment => "発送業者ID"
      t.column :name, :string, :comment => "発送時間名"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
      t.column :code, :string, :comment => "発送伝票番号"
    end
    add_index :delivery_times, :deleted_at
    add_index :delivery_times, :delivery_trader_id
    add_index :delivery_times, :position
  end

  def self.down
    remove_index :delivery_times, :position
    remove_index :delivery_times, :delivery_trader_id
    remove_index :delivery_times, :deleted_at
    drop_table :delivery_times
  end
end
