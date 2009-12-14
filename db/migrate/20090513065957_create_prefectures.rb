class CreatePrefectures < ActiveRecord::Migration
  def self.up
    create_table :prefectures do |t|
      t.column :name,       :string,    :comment => '都道府県名'
      t.column :position,   :integer,   :comment => '順番'
      t.column :created_at, :datetime,  :comment => '作成日'
      t.column :updated_at, :datetime,  :comment => '更新日'
      t.column :deleted_at, :datetime,  :comment => '削除日'
    end
    add_index :prefectures, :deleted_at
    add_index :prefectures, :position

    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "prefectures")
  end

  def self.down
    remove_index :prefectures, :position
    remove_index :prefectures, :deleted_at
    drop_table :prefectures
  end
end
