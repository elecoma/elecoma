class CreateRecommends < ActiveRecord::Migration
  def self.up
    create_table :recommends do |t|
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :request_type, :integer, :comment => 'リクエストタイプ'
    end
  end

  def self.down
    drop_table :recommends
  end
end
