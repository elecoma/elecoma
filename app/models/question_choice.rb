class QuestionChoice < ActiveRecord::Base

  acts_as_paranoid

  NOUSE, TEXTAREA, TEXTBOX, CHECKBOX, RADIOBUTTON = 0, 1, 2, 3, 4
  CHOICE_FORMAT = { NOUSE => "使用しない", TEXTAREA => "テキストエリア",
                    TEXTBOX => "テキストボックス", CHECKBOX => "チェックボックス",
                    RADIOBUTTON => "ラジオボタン" }
  belongs_to :question

  def format_view
    CHOICE_FORMAT[format]
  end
  
end
