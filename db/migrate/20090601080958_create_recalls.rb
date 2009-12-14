class CreateRecalls < ActiveRecord::Migration
  def self.up
    create_table :recalls do |t|
      t.column :code,               :string,    :comment => '返品コード'
      t.column :order_delivery_id,  :integer,   :comment => '配達要望ID'
      t.column :count_up,           :boolean,    :comment => 'カウントアップ'
      t.column :created_at,         :datetime,  :comment => '作成日'
      t.column :updated_at,         :datetime,  :comment => '更新日'
      t.column :deleted_at,         :datetime,  :comment => '削除日'
    end
  end

  def self.down
    drop_table :recalls
  end
end
