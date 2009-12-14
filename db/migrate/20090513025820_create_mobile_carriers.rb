class CreateMobileCarriers < ActiveRecord::Migration
  def self.up
    create_table :mobile_carriers do |t|
      t.column :name,           :string,    :comment => 'キャリア名'
      t.column :jpmobile_class, :string,    :comment => 'jpmobileのクラス名'
      t.column :position,       :integer,   :comment => '順番'
      t.column :created_at,     :datetime,  :comment => '作成日'
      t.column :updated_at,     :datetime,  :comment => '更新日'
      t.column :deleted_at,     :datetime,  :comment => '削除日'
    end
    add_index :mobile_carriers, :deleted_at
    add_index :mobile_carriers, :position

    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "mobile_carriers")
  end

  def self.down
    remove_index :mobile_carriers, :position
    remove_index :mobile_carriers, :deleted_at
    drop_table :mobile_carriers
  end
end
