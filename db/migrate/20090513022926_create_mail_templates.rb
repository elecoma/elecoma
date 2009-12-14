class CreateMailTemplates < ActiveRecord::Migration
  def self.up
    create_table :mail_templates do |t|
      t.column :name, :string, :comment => 'テンプレート名'
      t.column :title, :string, :comment => 'メールタイトル'
      t.column :header, :text, :comment => 'メールヘッダー'
      t.column :footer, :text, :comment => 'メールフッター'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :mail_templates, :deleted_at
  end

  def self.down
    remove_index :mail_templates, :deleted_at
    drop_table :mail_templates
  end
end
