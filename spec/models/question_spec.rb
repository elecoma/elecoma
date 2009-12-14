require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question do
  fixtures :questions,:question_choices
  before(:each) do
    @question = questions(:question_id_1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @question.should be_valid
    end
  end
  describe "その他" do
    it "質問項目を削除" do      
      old_questions = Question.find(:all, :conditions=>["questionnaire_id=?", 1])
      old_questions.should_not be_empty

      question_ids = old_questions.map {|question| question.id}
      QuestionChoice.find(:all,:conditions=>["question_id in (?)",question_ids]).should_not be_empty
      
      #Questionの削除
      Question.clear_questions(old_questions)
      Question.find(:all, :conditions=>["questionnaire_id=?", 1]).should be_empty
      #Questionが削除されると、question_choiceも削除されるはず
      QuestionChoice.find(:all,:conditions=>["question_id in (?)",question_ids]).should be_empty
    end
  end
end
