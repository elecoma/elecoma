# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionChoice do
  fixtures :question_choices
  before(:each) do
    @question_choice = question_choices(:question_choice_id_1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @question_choice.should be_valid
    end
  end
  describe "表示系" do
    it "choice_format_view で値を返す" do
      @question_choice.format = QuestionChoice::RADIOBUTTON
      @question_choice.format_view.should == QuestionChoice::CHOICE_FORMAT[QuestionChoice::RADIOBUTTON]
    end    
  end
end
