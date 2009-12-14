class CreateFaqs < ActiveRecord::Migration
  def self.up
    create_table :faqs do |t|
      t.column :name, :string, :comment => 'お問い合わせ名'
      t.column :content, :string, :comment => 'お問い合わせ内容'
      t.column :site_type, :integer, :comment => 'サイトタイプ'
      t.column :category, :string, :comment => 'カテゴリー'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :faqs, :deleted_at
    add_index :faqs, :position
  end

  def self.down
    drop_table :faqs
  end
end
