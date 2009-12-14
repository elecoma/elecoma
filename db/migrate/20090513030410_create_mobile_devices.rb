class CreateMobileDevices < ActiveRecord::Migration
  def self.up
    create_table :mobile_devices do |t|
      t.column :mobile_carrier_id,  :integer,   :comment => 'キャリアID'
      t.column :device_name,        :string,    :comment => '端末機種名'
      t.column :user_agent,         :string,    :comment => 'ユーザーエージェント'
      t.column :width,              :integer,   :comment => '画面サイズ（横）'
      t.column :height,             :integer,   :comment => '画面サイズ（縦）'
      t.column :created_at,         :datetime,  :comment => '作成日'
      t.column :updated_at,         :datetime,  :comment => '更新日'
      t.column :deleted_at,         :datetime,  :comment => '削除日'
    end
    add_index :mobile_devices, :deleted_at

    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "mobile_devices")
  end

  def self.down
    remove_index :mobile_devices, :deleted_at
    drop_table :mobile_devices
  end
end
