# -*- coding: utf-8 -*-
class CreateQuestionAnswers < ActiveRecord::Migration
  def self.up
    create_table :question_answers do |t|
      t.column :questionnaire_answer_id, :integer, :comment => 'アンケート回答ID'
      t.column :question_id, :integer, :comment => '質問ID'
      t.column :question_choice_id, :integer, :comment => '質問形式ID'
      t.column :question_position, :integer, :commnet => '質問の出題順'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :answer, :text, :commnet => '回答'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :question_answers, :deleted_at
    add_index :question_answers, :question_choice_id
    add_index :question_answers, :question_id
    add_index :question_answers, :questionnaire_answer_id
  end

  def self.down
    remove_index :question_answers, :questionnaire_answer_id
    remove_index :question_answers, :question_id
    remove_index :question_answers, :question_choice_id
    remove_index :question_answers, :deleted_at
    drop_table :question_answers
  end
end
