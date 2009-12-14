require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionAnswer do
  fixtures :question_answers
  before(:each) do
    @question_answer = question_answers(:question_answer_id_1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @question_answer.should be_valid
    end
    it "回答" do
      #非必須
      @question_answer.answer = nil
      @question_answer.should be_valid
      #文字数チェック（200文字以下）
      @question_answer.answer = "あ" * 200
      @question_answer.should be_valid
      @question_answer.answer = "a" * 201
      @question_answer.should_not be_valid
    end
  end
  describe "その他" do
    it "配列を戻る" do
      question_answer = QuestionAnswer.new(:answer=>"アンケートの回答です")      
      question_answer.export_row.should == ["アンケートの回答です"]
    end
  end
end
