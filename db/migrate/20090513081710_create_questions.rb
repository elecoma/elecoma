class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.column :content, :text, :comment => '質問'
      t.column :questionnaire_id, :integer, :comment => 'アンケートID'
      t.column :position, :integer, :comment => '順番'
      t.column :question_choice_id, :integer, :comment => '質問の選択肢ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :questions, :deleted_at
    add_index :questions, :position
    add_index :questions, :question_choice_id
    add_index :questions, :questionnaire_id
  end

  def self.down
    remove_index :questions, :questionnaire_id
    remove_index :questions, :question_choice_id
    remove_index :questions, :position
    remove_index :questions, :deleted_at
    drop_table :questions
  end
end
