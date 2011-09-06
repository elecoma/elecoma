class CreateServiceCooperationsTemprates < ActiveRecord::Migration
  def self.up
    create_table :service_cooperations_templates do |t|
      t.string :template_name
      t.string :service_name
      t.string :url_file_name
      t.integer :file_type
      t.integer :encode
      t.integer :newline_character
      t.text :sql
      t.text :field_items
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :service_cooperations_templates
  end
end
