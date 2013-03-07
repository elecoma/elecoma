# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionnairesController do
  fixtures :zips, :questions, :questionnaires, :question_choices

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use QuestionnairesController" do
    controller.should be_an_instance_of(QuestionnairesController)
  end


  describe "GET 'new'" do
    it "アンケート新規回答画面が表示されている" do
      get 'new', :id =>1
      response.should be_success
      flash[:notice].should be_nil
    end

    it "アンケートが指定されていない" do
      get 'new'
      response.should be_success
    end

    it "アンケートが非公開" do
      get 'new', :id => 4
      response.should be_success
    end
  end

  describe "GET 'confirm'" do
    before(:each) do
      @respondent = {"customer_first_name"=>"てすと", "customer_family_name"=>"てすと", "customer_first_name_kana"=>"テスト", "customer_family_name_kana"=>"テスト",
                     "zipcode01"=>"111", "zipcode02"=>"1111", "prefecture_name"=>"都道府県", "address_city"=>"市区町村", "address_details"=>"地域",
                     "tel01"=>"000", "tel02"=>"0000", "tel03"=>"0000", "email"=>"aaa@aaaa.aa"}
      @answers = {"11"=>"textbox", "12"=>"textarea", "13"=>{"18"=>"on", "19"=>"on"}, "14"=>"belongs_to_queston_id_14_1"}
    end

    it "確認画面が表示できる" do
      get 'confirm', :id =>9, :respondent=>@respondent, :answers=>@answers
      response.should be_success
      #格納された回答数(=問題数)を確認
      assigns[:answers].size.should == questionnaires(:questionnaire_id_9).questions.size
    end

    it "validateにひっかかる(カスタマー情報)" do
      get 'confirm', :id => 9, :answers=>@answers
      response.should render_template("questionnaires/new.html.erb")
    end

    it "validateにひっかかる(回答情報(CheckBox以外))" do
      answers = {"11"=>"textboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextboxtextbox", "12"=>"textarea", "13"=>{"18"=>"on", "19"=>"on"}, "14"=>"belongs_to_queston_id_14_1"}

      get 'confirm', :id => 9, :respondent=>@respondent, :answers=>answers
      response.should render_template("questionnaires/new.html.erb")
    end

    it "validateにひっかかる(回答情報(CheckBox以外))" do
      answers = {"11"=>"textbox", "12"=>"textarea", "13"=>{"18"=>"on", "19"=>"ononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononon"}, "14"=>"belongs_to_queston_id_14_1"}

      get 'confirm', :id => 9, :respondent=>@respondent, :answers=>answers
      response.should render_template("questionnaires/new.html.erb")
    end
  end

  describe "GET 'complete'" do
    before(:each) do
      @respondent = {"customer_first_name"=>"てすと", "customer_family_name"=>"てすと", "customer_first_name_kana"=>"テスト", "customer_family_name_kana"=>"テスト",
                     "zipcode01"=>"111", "zipcode02"=>"1111", "prefecture_name"=>"都道府県", "address_city"=>"市区町村", "address_details"=>"地域",
                     "tel01"=>"000", "tel02"=>"0000", "tel03"=>"0000", "email"=>"aaa@aaaa.aa"}
      @answers = {"11"=>{"answer"=>"textbox"}, "12"=>{"answer"=>"textarea"}, "13"=>{"18"=>{"answer"=>"1"}, "19"=>{"answer"=>"1"},"20"=>{"answer"=>"0"}}, "14"=>{"answer"=>"belongs_to_queston_id_14_2"}}
    end

    it "データが保存できる" do
      old_records = QuestionnaireAnswer.count

      get 'complete', :id => 9, :respondent=>@respondent, :answers=>@answers
      response.should be_success
      QuestionnaireAnswer.count.should == old_records+1
    end

    it "保存に失敗する" do
      respondent = {"customer_first_name"=>"", "customer_family_name"=>"てすと", "customer_first_name_kana"=>"テスト", "customer_family_name_kana"=>"テスト",
                  "zipcode01"=>"111", "zipcode02"=>"1111", "prefecture_name"=>"都道府県", "address_city"=>"市区町村", "address_details"=>"地域",
                  "tel01"=>"000", "tel02"=>"0000", "tel03"=>"0000", "email"=>"aaa@aaaa.aa"}
      old_records = QuestionnaireAnswer.count

      get 'complete', :id => 9, :respondent=>respondent, :answers=>@answers
      response.should be_success
      QuestionnaireAnswer.count.should == old_records
    end
  end
end
