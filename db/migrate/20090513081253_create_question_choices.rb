class CreateQuestionChoices < ActiveRecord::Migration
  def self.up
    create_table :question_choices do |t|
      t.column :content, :string, :comment => '選択肢'
      t.column :format, :integer, :comment => '形式'
      t.column :question_id, :integer, :comment => '質問ID'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :question_choices, :deleted_at
    add_index :question_choices, :position
    add_index :question_choices, :question_id
  end

  def self.down
    remove_index :question_choices, :question_id
    remove_index :question_choices, :position
    remove_index :question_choices, :deleted_at
    drop_table :question_choices
  end
end
