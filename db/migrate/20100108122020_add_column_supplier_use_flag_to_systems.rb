class AddColumnSupplierUseFlagToSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :supplier_use_flag, :boolean,:default => false, :comment => "仕入先使用可否"    
  end

  def self.down
    remove_columns :systems, :supplier_use_flag
  end
end
