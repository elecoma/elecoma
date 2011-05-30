class CreateServiceCooperations < ActiveRecord::Migration
  def self.up
    create_table :service_cooperations do |t|
      t.string :name
      t.boolean :enable
      t.string :url_file_name
      t.integer :file_type
      t.integer :encode
      t.integer :newline_character
      t.text :sql
      t.string :field_items
      t.timestamps
    end
  end

  def self.down
    drop_table :service_cooperations
  end
end
