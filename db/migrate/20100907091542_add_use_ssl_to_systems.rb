class AddUseSslToSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :use_ssl, :boolean, :default => false
  end

  def self.down
    remove_column :systems, :use_ssl
  end
end
