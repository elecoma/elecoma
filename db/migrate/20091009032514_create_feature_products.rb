class CreateFeatureProducts < ActiveRecord::Migration
  def self.up
    create_table :feature_products do |t|
      
      t.column :product_id,       :integer,     :comment => '商品ID'
      t.column :feature_id,       :integer,     :comment => '特集ID'
      t.column :position,         :integer,     :comment => '表示順'
      t.column :image_resource_id,:integer,     :comment => '商品画像'
      t.column :body,             :text,        :comment => 'フリースペース'
      t.timestamps
      t.timestamp :deleted_at
    end
  end
  
  def self.down
    drop_table :feature_products
  end
end
