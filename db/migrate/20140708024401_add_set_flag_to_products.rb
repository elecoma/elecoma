class AddSetFlagToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :set_flag, :boolean
  end

  def self.down
    remove_column :products, :set_flag
  end
end
