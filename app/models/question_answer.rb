# -*- coding: utf-8 -*-
class QuestionAnswer < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :questionnaire_answer
  belongs_to :question
  belongs_to :question_choice

  validates_length_of  :answer, :maximum=>200, :to_long=>"は最大%d文字です", :allow_nil => true

  def export_row
    array = []
    columns = ["answer"]
    for column in columns
        value = self[column]
      array << value
    end
    return array
  end

end
