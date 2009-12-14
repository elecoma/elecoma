class CreateMailMagazineTemplates < ActiveRecord::Migration
  def self.up
    create_table :mail_magazine_templates do |t|
      t.column :form,       :integer,   :comment => 'メール形式'
      t.column :subject,    :string,    :comment => '件名'
      t.column :body,       :text,      :comment => '本文'
      t.column :created_at, :datetime,  :comment => '作成日'
      t.column :updated_at, :datetime,  :comment => '更新日'
      t.column :deleted_at, :datetime,  :comment => '削除日'
    end
    add_index :mail_magazine_templates, :deleted_at
  end

  def self.down
    remove_index :mail_magazine_templates, :deleted_at
    drop_table :mail_magazine_templates
  end
end
