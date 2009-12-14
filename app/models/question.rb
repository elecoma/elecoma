class Question < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :questionnaire
  has_many :question_choices, :dependent => :destroy

  
  #質問項目を削除
  def self.clear_questions(questions)
    begin
      Question.transaction do
        questions.each do |question|
          question.question_choices.clear
          question.destroy
        end
      end
      return true
    rescue
      return false
    end
  end

end
