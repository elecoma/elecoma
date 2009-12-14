class CreateDeliveryTickets < ActiveRecord::Migration
  def self.up
    create_table :delivery_tickets do |t|
      t.column :order_delivery_id, :integer, :comment => "発送ID"
      t.column :code, :string, :comment => "発送伝票番号"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
  end

  def self.down
    drop_table :delivery_tickets
  end
end
