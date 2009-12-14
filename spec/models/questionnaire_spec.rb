require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Questionnaire do
  fixtures :questionnaires, :questions, :questionnaire_answers,:question_choices,:question_answers
  before(:each) do
    @questionnaire = Questionnaire.new
  end
  describe "validateチェック" do
    before(:each) do
      init_test_data      
    end    
    it "データが正しい" do
      @questionnaire.should be_valid
    end
    it "タイトル" do
      #必須チェック
      @questionnaire.name = nil
      @questionnaire.should_not be_valid
      #文字数チェック(300文字以下)
      @questionnaire.name = "a" * 300
      @questionnaire.should be_valid
      @questionnaire.name = "a" * 301
      @questionnaire.should_not be_valid        
    end
    it "アンケート内容" do
      #必須チェック
      @questionnaire.content = nil
      @questionnaire.should_not be_valid
    end
    it "質問項目チェック1" do
      #必須チェック
      #質問がありません
      @questionnaire.questions = []
      @questionnaire.should_not be_valid      
    end
    it "質問項目チェック2" do
      #質問1がありません
      #選択があるが、質問１が選択されていない
      @questionnaire.questions[0].position = 2
      @questionnaire.should_not be_valid
    end
    it "質問項目チェック3" do
      #質問Nの内容がありません
      @questionnaire.questions[1].content = nil
      @questionnaire.should_not be_valid
    end
    it "質問項目チェック4" do
      #質問Nの内容が10万文字以上
      @questionnaire.questions[1].content = "a" * 100000
      @questionnaire.should be_valid
      @questionnaire.questions[1].content = "a" * 100001
      @questionnaire.should_not be_valid
    end

    it "質問形式が選択されていません" do
      #質問Nの質問形式が選択されていません
      @questionnaire.questions[1].question_choices[0] = QuestionChoice.new
      @questionnaire.should_not be_valid
    end
    it "選択肢1がありません" do
      #質問Nの選択肢1がありません
      #このチェックはformatがCHECKBO||RADIOBUTTONの場合のみ
      @questionnaire.questions[1].question_choices[0] = QuestionChoice.new(:format=>QuestionChoice::CHECKBOX)
    end
  end
  describe "その他" do
    it "初期化" do
      #初期化前
      @questionnaire.questions.should be_empty
      #初期化
      @questionnaire.init_data
      #初期化後
      @questionnaire.questions.size.should == Questionnaire::QUESTION_COUNT
      @questionnaire.questions.each_with_index do |question,i|
        question.content.should be_nil
        question.position.should == i+1
        question.question_choices.size.should == Questionnaire::QUESTION_CHOICE_COUNT
        question.question_choices.each_with_index do |choice,i|
          choice.content.should be_nil
          choice.format.should be_nil
          choice.position.should == i+1
        end
      end
    end
    it "表示用アンケートデータ取得" do
      #メソッド呼び出し前
      @questionnaire = questionnaires(:questionnaire_id_9)
      cnt_questions = Question.find(:all,:conditions=>["questionnaire_id = ?",@questionnaire.id]).size
      @questionnaire.questions.size.should == cnt_questions
      question_ids = @questionnaire.questions.map {|question| question.id}
      @questionnaire.questions.each do |question|
        question.question_choices.size.should == QuestionChoice.find(:all,:conditions=>["question_id = ?",question.id]).size
      end
      #メソッド呼び出し
      questions = @questionnaire.get_show_questions_data
      #メソッド呼出し後
      #期待結果
      #1.questionsのサイズはQuestionnaire::QUESTION_COUNTである
      questions.size.should == Questionnaire::QUESTION_COUNT
      questions.each_with_index do |question,i|
        #2.DBに登録されていない分は選択肢を新しく追加
        if question.id.nil?
          question.content.should be_nil
          question.position.should == i+1
        end
        #3.questionごとにquestion_choices.sizeがQuestionnaire::QUESTION_CHOICE_COUNTである
        question.question_choices.size.should == Questionnaire::QUESTION_CHOICE_COUNT
        question.question_choices.each_with_index do |choice,i|
          #4.DBに登録されていない分は選択肢を新しく追加
          if choice.id.nil?
            choice.content.should be_nil
            choice.format.should be_nil
            choice.position.should == i+1
          end
        end
      end      
    end
  describe "CSVダウンロード" do
    it "CSVダウンロード" do
      actual_titles,actual_datas = getCsv(Questionnaire.csv(questionnaires(:questionnaire_id_1).id, Questionnaire::QUESTION_COUNT))

      #タイトル
      act = actual_titles.sort
      ext = Questionnaire.get_csv_header(Questionnaire::QUESTION_COUNT).sort
      act.should == ext
      #データ内容
      columns = ["id", "customer_family_name", "customer_first_name", "customer_family_name_kana", "customer_first_name_kana", "customer_id",
               "zipcode01", "zipcode02", "prefecture_name", "address_city", "address_details", "tel01", "tel02", "tel03",
               "created_at", "email"]
      #データ比較
      actual_datas.should == convert(questionnaires(:questionnaire_id_1).questionnaire_answers,columns)
    end
  end
    
  end
  #=============================================
  private
  def init_test_data
    @questionnaire.name = "テストコード"
    @questionnaire.content = "テストコードです"
    @questionnaire.operation = false
    #選択された項目内容設定
    #ここでは3質問で、一つずづ
    3.times do |question_idx|
      question = Question.new(:content=>"アンケートテスト", :position=>question_idx+1)
      2.times do |choice_idx|
        question.question_choices << QuestionChoice.new(:content=>"アンケートテストです",:format=>choice_idx+1, :position=>choice_idx+1)        
      end
      @questionnaire.questions << question
    end
  end
  #fixturesデータをCSV形式に変換（比較用）
  def convert(questionnaire_answers, columns)
    datas = []
    questionnaire_answers.each do |qa|
      arr = []
      columns.each do |c|
        #更新時間について、
        #questionnaire_answer.created_atとquestionnaire_answer[created_at]の結果が違うので特別処理
        if "created_at" == c
          arr << (qa.created_at.nil? ? "" : qa.created_at.strftime('%Y-%m-%d %H:%M:%S'))
        else  
          arr << (qa[c].nil? ? "" : qa[c].to_s)
        end      
      end
      #回答1-6
      Questionnaire::QUESTION_COUNT.times do |i|
        arr << (qa.question_answers[i].nil? ? "" :  qa.question_answers[i].answer.to_s)
      end
      datas << arr.join(",").split(",")
    end
    datas
  end  
  #CSVダウンロードデータを比較用データに変換
  def getCsv(datas)
    
    #タイトル
    actual_titles = []
    #データ
    actual_datas = []
    datas.split("\n").each_with_index do |d,i|
      if i == 0
        actual_titles = d.split(/\s*,\s*/)
      else
        actual_datas << d.split(/\s*,\s*/)
      end
    end
    return actual_titles ,actual_datas
  end  
end
