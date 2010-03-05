class RenameColumnConstants < ActiveRecord::Migration
  def self.up
    rename_column :constants, :key, :const_key
  end

  def self.down
    rename_column :constants, :const_key, :key
  end
end
