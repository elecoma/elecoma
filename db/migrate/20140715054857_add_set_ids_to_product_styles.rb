class AddSetIdsToProductStyles < ActiveRecord::Migration
  def self.up
    add_column :product_styles, :set_ids, :string
  end

  def self.down
    remove_column :product_styles, :set_ids
  end
end
