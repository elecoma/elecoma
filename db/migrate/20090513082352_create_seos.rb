class CreateSeos < ActiveRecord::Migration
  def self.up
    create_table :seos do |t|
      t.column :name, :string, :comment => 'ページ名'
      t.column :author, :string, :comment => 'メタタグ:author'
      t.column :description, :string, :comment => 'メタタグ:Description'
      t.column :keywords, :string, :comment => 'メタタグ:Keywords'
      t.column :page_type, :integer, :comment => 'ページタイプ'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :seos, :page_type
  end

  def self.down
    remove_index :seos, :page_type
    drop_table :seos
  end
end
