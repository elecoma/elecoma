class CreateRecommendXmls < ActiveRecord::Migration
  def self.up
    create_table :recommend_xmls do |t|
      t.column :recommend_id, :string, :comment => 'レコメンドID'
      t.column :name, :string, :comment => '商品名'
      t.column :url, :string, :comment => '商品詳細画面URL'
      t.column :categroy, :string, :comment => 'カテゴリー名'
      t.column :price, :string, :comment => '商品価格'
      t.column :image_url, :string, :comment => 'イメージ画像URL'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :request_type, :integer, :comment => 'リクエストタイプ'
    end
  end

  def self.down
    drop_table :recommend_xmls
  end
end
