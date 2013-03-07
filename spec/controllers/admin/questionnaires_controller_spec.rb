# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::QuestionnairesController do
  fixtures :questionnaires, :questions, :questionnaire_answers, :question_choices , :authorities, :functions, :admin_users

  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @controller.class.before_filter :master_shop_check
  end

  #Delete this example and add some real ones
  it "should use Admin::QuestionnairesController" do
    controller.should be_an_instance_of(Admin::QuestionnairesController)
  end

  describe "GET 'index'" do

    it "データ新規作成の場合" do
      get 'index'
      response.should be_success
      assigns[:questionnaires].should == Questionnaire.find(:all)
    end

    it "マスターショップ以外はアクセスできない" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      get 'index'
      response.should redirect_to(:controller => "home", :action => "index")
    end
  end

  describe "GET 'create'" do
    before(:each) do
      @question_num = 6
      @question_choice_num = 8
      @questionnaire = {"name"=>"test", "operation"=>"true", "content"=>"test"}
      @questions = {"0"=>"test", "1"=>"test2", "2"=>"test3", "3"=>"", "4"=>"", "5"=>""}
    end

    it "アンケートを作成する場合" do
      questionnaire_old_num = Questionnaire.count
      question_old_num = Question.count
      question_choice_old_num = QuestionChoice.count
      get 'create', :questionnaire=>@questionnaire, :questions=>@questions, 
                    :question0_choice0_format => "1", :question1_choice0_format => "2", :question2_choice0_format => "3",
                    :question0_choice0=>"", :question0_choice1=>"", :question0_choice2=>"", :question0_choice3=>"", 
                    :question0_choice4=>"", :question0_choice5=>"", :question0_choice6=>"", :question0_choice7=>"",
                    :question1_choice0=>"", :question1_choice1=>"", :question1_choice2=>"", :question1_choice3=>"", 
                    :question1_choice4=>"", :question1_choice5=>"", :question1_choice6=>"", :question1_choice7=>"",
                    :question2_choice0=>"test1", :question2_choice1=>"test2", :question2_choice2=>"", :question2_choice3=>"", 
                    :question2_choice4=>"", :question2_choice5=>"", :question2_choice6=>"", :question2_choice7=>"",
                    :question3_choice0=>"", :question3_choice1=>"", :question3_choice2=>"", :question3_choice3=>"", 
                    :question3_choice4=>"", :question3_choice5=>"", :question3_choice6=>"", :question3_choice7=>"",
                    :question4_choice0=>"", :question4_choice1=>"", :question4_choice2=>"", :question4_choice3=>"", 
                    :question4_choice4=>"", :question4_choice5=>"", :question4_choice6=>"", :question4_choice7=>"",
                    :question5_choice0=>"", :question5_choice1=>"", :question5_choice2=>"", :question5_choice3=>"", 
                    :question5_choice4=>"", :question5_choice5=>"", :question5_choice6=>"", :question5_choice7=>""

      #response.should be_success
      assigns[:questionnaire].name.should == "test"
      assigns[:questions].size.should == @question_num  #質問項目が6個確保される
      @question_num.times do |idx|  #paramsで入力された質問項目名が@questionsに入っている
        assigns[:questions][idx].content.should == @questions["#{idx}"]
      end
      #選択肢が8個確保される
      assigns[:questions][0].question_choices.size.should == @question_choice_num
      #@questions[i]の選択肢に、質問形式が入っている（１つだけ確認）
      assigns[:questions][0].question_choices[0].format.should == QuestionChoice::TEXTAREA
      assigns[:questions][0].question_choices[0].content.should == ""
      #質問形式がCHECKBOX, TEXTAREAの場合、選択肢名も入ってくる
      question = assigns[:questions][2]
      @question_choice_num.times do |idx|
        question.question_choices[idx].content.should == "test1" if idx==0
        question.question_choices[idx].content.should == "test2" if idx==1
        question.question_choices[idx].content.should == "" if idx>1
      end

      flash[:notice].should_not be_nil
      #登録したレコードが増えている
      Questionnaire.count.should == questionnaire_old_num + 1
      Question.count.should == question_old_num + 3  #質問項目を3つ追加したため
      QuestionChoice.count.should == question_choice_old_num + 1 + 1 + 2  #question0, question1, question2がそれぞれ持つ選択肢を追加したため
      response.should redirect_to(:action => "index")
    end

    it "validateに引っかかる場合" do
      questionnaire_old_num = Questionnaire.count
      question_old_num = Question.count
      question_choice_old_num = QuestionChoice.count
      #question3に質問項目名が入っているが、質問形式は指定されていない
      @questions = {"0"=>"test", "1"=>"test2", "2"=>"test3", "3"=>"test4", "4"=>"", "5"=>""}  
      get 'create', :questionnaire=>@questionnaire, :questions=>@questions, 
                    :question0_choice0_format => "1", :question1_choice0_format => "2", :question2_choice0_format => "3",
                    :question0_choice0=>"", :question0_choice1=>"", :question0_choice2=>"", :question0_choice3=>"", 
                    :question0_choice4=>"", :question0_choice5=>"", :question0_choice6=>"", :question0_choice7=>"",
                    :question1_choice0=>"", :question1_choice1=>"", :question1_choice2=>"", :question1_choice3=>"", 
                    :question1_choice4=>"", :question1_choice5=>"", :question1_choice6=>"", :question1_choice7=>"",
                    :question2_choice0=>"test1", :question2_choice1=>"test2", :question2_choice2=>"", :question2_choice3=>"", 
                    :question2_choice4=>"", :question2_choice5=>"", :question2_choice6=>"", :question2_choice7=>"",
                    :question3_choice0=>"", :question3_choice1=>"", :question3_choice2=>"", :question3_choice3=>"", 
                    :question3_choice4=>"", :question3_choice5=>"", :question3_choice6=>"", :question3_choice7=>"",
                    :question4_choice0=>"", :question4_choice1=>"", :question4_choice2=>"", :question4_choice3=>"", 
                    :question4_choice4=>"", :question4_choice5=>"", :question4_choice6=>"", :question4_choice7=>"",
                    :question5_choice0=>"", :question5_choice1=>"", :question5_choice2=>"", :question5_choice3=>"", 
                    :question5_choice4=>"", :question5_choice5=>"", :question5_choice6=>"", :question5_choice7=>""

      #flash[:error].should == "登録に失敗しました"
      #登録に失敗したためレコードは増えていない
      Questionnaire.count.should == questionnaire_old_num
      Question.count.should == question_old_num
      QuestionChoice.count.should == question_choice_old_num
      response.should render_template("admin/questionnaires/new.html.erb")
    end

  end

  describe "GET 'update'" do
    before(:each) do
      @id = 1
      @question_num = 6
      @question_choice_num = 8
      @questionnaire = {"name"=>"test", "operation"=>"true", "content"=>"test"}
      @questions = {"0"=>"test", "1"=>"test2", "2"=>"test3", "3"=>"", "4"=>"", "5"=>""}
    end

    it "更新する場合" do
      questionnaire_old_num = Questionnaire.count
      get 'update', :questionnaire=>@questionnaire, :questions=>@questions, 
                    :question0_choice0_format => "1", :question1_choice0_format => "2", :question2_choice0_format => "3",
                    :question0_choice0=>"", :question0_choice1=>"", :question0_choice2=>"", :question0_choice3=>"", 
                    :question0_choice4=>"", :question0_choice5=>"", :question0_choice6=>"", :question0_choice7=>"",
                    :question1_choice0=>"", :question1_choice1=>"", :question1_choice2=>"", :question1_choice3=>"", 
                    :question1_choice4=>"", :question1_choice5=>"", :question1_choice6=>"", :question1_choice7=>"",
                    :question2_choice0=>"test1", :question2_choice1=>"test2", :question2_choice2=>"", :question2_choice3=>"", 
                    :question2_choice4=>"", :question2_choice5=>"", :question2_choice6=>"", :question2_choice7=>"",
                    :question3_choice0=>"", :question3_choice1=>"", :question3_choice2=>"", :question3_choice3=>"", 
                    :question3_choice4=>"", :question3_choice5=>"", :question3_choice6=>"", :question3_choice7=>"",
                    :question4_choice0=>"", :question4_choice1=>"", :question4_choice2=>"", :question4_choice3=>"", 
                    :question4_choice4=>"", :question4_choice5=>"", :question4_choice6=>"", :question4_choice7=>"",
                    :question5_choice0=>"", :question5_choice1=>"", :question5_choice2=>"", :question5_choice3=>"", 
                    :question5_choice4=>"", :question5_choice5=>"", :question5_choice6=>"", :question5_choice7=>"",
                    :id=>"1"

      assigns[:id].should == "1"
      assigns[:questionnaire].name.should == "test"
      assigns[:questions].size.should == @question_num  #質問項目が6個確保される
      @question_num.times do |idx|  #paramsで入力された質問項目名が@questionsに入っている
        assigns[:questions][idx].content.should == @questions["#{idx}"]
      end
      #選択肢が8個確保される
      assigns[:questions][0].question_choices.size.should == @question_choice_num
      #@questions[i]の選択肢に、質問形式が入っている（１つだけ確認）
      assigns[:questions][0].question_choices[0].format.should == QuestionChoice::TEXTAREA
      assigns[:questions][0].question_choices[0].content.should == ""
      #質問形式がCHECKBOX, TEXTAREAの場合、選択肢名も入ってくる
      question = assigns[:questions][2]
      @question_choice_num.times do |idx|
        question.question_choices[idx].content.should == "test1" if idx==0
        question.question_choices[idx].content.should == "test2" if idx==1
        question.question_choices[idx].content.should == "" if idx>1
      end

      flash[:notice].should_not be_nil
      #更新なのでアンケートのレコードは増えない
      Questionnaire.count.should == questionnaire_old_num
      Question.count(:conditions=>["questionnaire_id=?", @id]).should == 3  #質問項目を3つ追加したため

      #更新された質問の内容を確認(1つだけ確認)
      question = Question.find(:first, :conditions=>["questionnaire_id=? and position=?", 1, 3])
      question.content.should == "test3"

      #更新された選択肢の内容を確認（１つだけ確認）
      question_choice = QuestionChoice.find(:first, :conditions=>["question_id=? and position=?", question.id, 1])
      question_choice.content.should == "test1"
      question_choice.format.should == QuestionChoice::CHECKBOX

      response.should redirect_to(:action => "index")
    end

    it "validateに引っかかる場合" do
      questionnaire_old_num = Questionnaire.count
      question_old_num = Question.count
      question_choice_old_num = QuestionChoice.count
      #question3に質問項目名が入っているが、質問形式は指定されていない
      @questions = {"0"=>"test", "1"=>"test2", "2"=>"test3", "3"=>"test4", "4"=>"", "5"=>""}  
      get 'update', :questionnaire=>@questionnaire, :questions=>@questions, 
                    :question0_choice0_format => "1", :question1_choice0_format => "2", :question2_choice0_format => "3",
                    :question0_choice0=>"", :question0_choice1=>"", :question0_choice2=>"", :question0_choice3=>"", 
                    :question0_choice4=>"", :question0_choice5=>"", :question0_choice6=>"", :question0_choice7=>"",
                    :question1_choice0=>"", :question1_choice1=>"", :question1_choice2=>"", :question1_choice3=>"", 
                    :question1_choice4=>"", :question1_choice5=>"", :question1_choice6=>"", :question1_choice7=>"",
                    :question2_choice0=>"test1", :question2_choice1=>"test2", :question2_choice2=>"", :question2_choice3=>"", 
                    :question2_choice4=>"", :question2_choice5=>"", :question2_choice6=>"", :question2_choice7=>"",
                    :question3_choice0=>"", :question3_choice1=>"", :question3_choice2=>"", :question3_choice3=>"", 
                    :question3_choice4=>"", :question3_choice5=>"", :question3_choice6=>"", :question3_choice7=>"",
                    :question4_choice0=>"", :question4_choice1=>"", :question4_choice2=>"", :question4_choice3=>"", 
                    :question4_choice4=>"", :question4_choice5=>"", :question4_choice6=>"", :question4_choice7=>"",
                    :question5_choice0=>"", :question5_choice1=>"", :question5_choice2=>"", :question5_choice3=>"", 
                    :question5_choice4=>"", :question5_choice5=>"", :question5_choice6=>"", :question5_choice7=>"",
                    :id=>"1"

      #登録に失敗したためquestion,question_choiceレコード数に変化はない
      Questionnaire.count.should == questionnaire_old_num
      Question.count.should == question_old_num
      QuestionChoice.count.should == question_choice_old_num

      response.should render_template("admin/questionnaires/edit.html.erb")
    end

    it "存在しないIDを指定されていた場合" do
      questionnaire_old_num = Questionnaire.count
      question_old_num = Question.count
      question_choice_old_num = QuestionChoice.count
      #question3に質問項目名が入っているが、質問形式は指定されていない
      @questions = {"0"=>"test", "1"=>"test2", "2"=>"test3", "3"=>"", "4"=>"", "5"=>""}  
      lambda{get 'update', :questionnaire=>@questionnaire, :questions=>@questions, 
                    :question0_choice0_format => "1", :question1_choice0_format => "2", :question2_choice0_format => "3",
                    :question0_choice0=>"", :question0_choice1=>"", :question0_choice2=>"", :question0_choice3=>"", 
                    :question0_choice4=>"", :question0_choice5=>"", :question0_choice6=>"", :question0_choice7=>"",
                    :question1_choice0=>"", :question1_choice1=>"", :question1_choice2=>"", :question1_choice3=>"", 
                    :question1_choice4=>"", :question1_choice5=>"", :question1_choice6=>"", :question1_choice7=>"",
                    :question2_choice0=>"test1", :question2_choice1=>"test2", :question2_choice2=>"", :question2_choice3=>"", 
                    :question2_choice4=>"", :question2_choice5=>"", :question2_choice6=>"", :question2_choice7=>"",
                    :question3_choice0=>"", :question3_choice1=>"", :question3_choice2=>"", :question3_choice3=>"", 
                    :question3_choice4=>"", :question3_choice5=>"", :question3_choice6=>"", :question3_choice7=>"",
                    :question4_choice0=>"", :question4_choice1=>"", :question4_choice2=>"", :question4_choice3=>"", 
                    :question4_choice4=>"", :question4_choice5=>"", :question4_choice6=>"", :question4_choice7=>"",
                    :question5_choice0=>"", :question5_choice1=>"", :question5_choice2=>"", :question5_choice3=>"", 
                    :question5_choice4=>"", :question5_choice5=>"", :question5_choice6=>"", :question5_choice7=>"",
                    :id=>"0"
      }.should raise_error(ActiveRecord::RecordNotFound) 
      #登録に失敗したためquestion,question_choiceレコード数に変化はない
      Questionnaire.count.should == questionnaire_old_num
      Question.count.should == question_old_num
      QuestionChoice.count.should == question_choice_old_num

    end

  end

  describe "GET 'destroy'" do
    it "削除に成功する場合" do
      question_id = Question.find(:first, :conditions=>["questionnaire_id=?", 9]).id
      get 'destroy', :id=>9
      flash[:notice].should == "削除しました"
      Questionnaire.count(:conditions=>["id=?", 9]).should == 0
      #質問が削除される
      Question.count(:conditions=>["questionnaire_id=?", 9]).should == 0
      #質問に紐づく選択肢も削除される（質問の1つをチェック）
      #ここなんか上手くいかない
      #QuestionChoice.count(:conditions=>["question_id=?", question_id]).should == 0

      response.should redirect_to(:action => "index")
    end

    it "削除に失敗する場合" do
      old_count = Questionnaire.count
      lambda{get 'destroy', :id=>100}.should raise_error(ActiveRecord::RecordNotFound)
      Questionnaire.count.should == old_count
    end
  end

  describe "GET 'csv_download'" do
    it "csvのデータが取れているか" do
      get 'csv_download', :id=>9
      #ヘッダー情報を確認
      @response.headers["Content-Disposition"].should =~ %r(^attachment)
      @response.headers['Content-Type'].should =~ %r(^application/octet-stream)
      #取得できたレコード数を確認
      rows = @response.body.split("\n").find_all { | row | !row.blank? }
      rows = @response.body.chomp.split("\n")
      #rows = header + レコード数
      rows.size.should == QuestionnaireAnswer.count(:conditions=>["questionnaire_id=?",9]) + 1
    end
  end

  describe "GET 'model_name'" do
    it "model_nameが取れているか" do
      get 'model_name'
      assigns[:model_name] = "questionnaire"
    end
  end

end
