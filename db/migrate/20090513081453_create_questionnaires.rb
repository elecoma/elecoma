class CreateQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :questionnaires do |t|
      t.column :name, :string, :comment => 'タイトル'
      t.column :content, :text, :comment => 'アンケート内容'
      t.column :operation, :boolean, :comment => '稼働/非稼働'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :questionnaires, :deleted_at
  end

  def self.down
    remove_index :questionnaires, :deleted_at
    drop_table :questionnaires
  end
end
