class CreateOccupations < ActiveRecord::Migration
  def self.up
    create_table :occupations do |t|
      t.column :name,       :string,    :comment => '職業名'
      t.column :position,   :integer,   :comment => '順番'
      t.column :created_at, :datetime,  :comment => '作成日'
      t.column :updated_at, :datetime,  :comment => '更新日'
      t.column :deleted_at, :datetime,  :comment => '削除日'
    end
    add_index :occupations, :deleted_at
    add_index :occupations, :position
  end

  def self.down
    remove_index :occupations, :position
    remove_index :occupations, :deleted_at
    drop_table :occupations
  end
end
