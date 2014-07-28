class CreateProductSets < ActiveRecord::Migration
  def self.up
    create_table :product_sets do |t|
      t.string :code
      t.integer :product_id
      t.string :product_style_ids
      t.string :ps_counts
      t.integer :set_count
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :product_sets
  end
end
