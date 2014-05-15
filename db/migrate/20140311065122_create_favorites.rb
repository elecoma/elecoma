class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :customer_id
      t.integer :product_style_id
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :favorites
  end
end
