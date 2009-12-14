class CreateConstants < ActiveRecord::Migration
  def self.up
    create_table :constants do |t|
      t.column :value, :string, :comment => "パラメータ値"
      t.column :created_at, :datetime, :comment => "作成日"
      t.column :updated_at, :datetime, :comment => "更新日"
      t.column :position, :integer, :comment => "順番"
      t.column :key, :integer, :comment => "キー"
      t.column :deleted_at, :datetime, :comment => "削除日"
    end
    add_index :constants, :deleted_at
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "constants")
  end

  def self.down
    remove_index :constants, :deleted_at
    drop_table :constants
  end
end
