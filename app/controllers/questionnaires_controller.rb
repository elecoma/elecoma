#class QuestionnairesController < ApplicationController
class QuestionnairesController < BaseController
  before_filter :get_questionnaire

  def complete
    questionnaire_answer = QuestionnaireAnswer.new params[:respondent]
    questionnaire_answer.questionnaire_name = @questionnaire.name
    questionnaire_answer.customer_id = Customer.find_by_email(params[:respondent][:email]).id if Customer.find_by_email(params[:respondent][:email])

    answers = []
    @questions.each do | question |
      #checkboxのものは一つのQuestionAnswerにまとめる: ex. answer = "1 2 3"
      if question.question_choices[0][:format] == QuestionChoice::CHECKBOX
        check_box_answer = [] #answer部分を初期化（この時点では）params[:answers]["#{question.id}"]["#{question_choice.id}"]のanswerが入っている
        question_choices = question.question_choices.find(:all, :order=>"position") #position順に回答を格納していく
        question_choices.each_with_index do | question_choice, index |
          check_box_answer << question_choice.content if params[:answers]["#{question.id}"]["#{question_choice.id}"][:answer] == "on"
        end
        answer = QuestionAnswer.new(params[:answers]["#{question.id}"]["#{question.question_choices[0].id}"])
        answer.answer = check_box_answer.join(' ')
        answers << answer
      else
        answers << QuestionAnswer.new(params[:answers]["#{question.id}"])
      end
    end

    flash.now[:notice] = "アンケートにご協力頂き、ありがとうございました"
    begin
      #アンケート回答の保存
      @questionnaire.questionnaire_answers<<(questionnaire_answer)
      questionnaire_answer.save!
      #質問回答の保存
      answers.each do | answer |
        questionnaire_answer.question_answers<<(answer)
        questionnaire_answer.save!
      end
    rescue
      flash.now[:notice] = "送信に失敗しました"
    end
  end

  def confirm
    #回答フォーム名規則
    #params[:answers][question_idx][choice_idx] => 質問番号の回答(answer)が入っている
    #params[:respondent] => 回答者情報
    @respondent = QuestionnaireAnswer.new params[:respondent]
    @answers = []    #paramsから渡ってきた回答を入れる
    #@answer_objects = Hash.new    #@questionnaire_answerに入れるためのオブジェクト(QuestionAnswer)を入れる

    @questions.each_with_index do | question, question_idx |
      answer_objects = []  #質問単位の回答

      if question.question_choices[0][:format] == QuestionChoice::CHECKBOX #回答形式がチェックボックスのときはquestion_choice分の回答を取得
        #チェックボックスの選択肢を取得
        question_choices = question.question_choices.find(:all,
                                                          :conditions=>["question_id=?", question.id],
                                                          :order=>"position")
        question_choices.each_with_index do | question_choice, choice_idx |
          #チェックされた選択肢を取得
          answer = params[:answers]["#{question.id}"]["#{question_choice.id}"] if params[:answers] && params[:answers]["#{question.id}"]
          answer_object = new_answer_object(question.id, question_choice.id, question.position, answer)
        #validateに引っかかったらnewに戻る
        answer_objects << answer_object
          unless answer_object.valid?
            render :action => "new", :id => @questionnaire.id
            return
          end
        end

      else #回答形式がチェックボックス以外のときは1つの回答を取得
        answer = params[:answers]["#{question.id}"] if params[:answers] && params[:answers]["#{question.id}"]  #QuectonChoice::NOUSEでは回答が存在しない

        question_choice_id = question.question_choices[0].id
        if question.question_choices[0][:format] == QuestionChoice::RADIOBUTTON #回答形式がラジオボタンのときは、選択肢名を回答に入れる
          question_choice_id = question.question_choices.find(:first,
                                                              :conditions=>["content=?", answer],
                                                              :select=>"id").id if answer
        end
        #質問回答を１つ取得
        answer_object = new_answer_object(question.id, question_choice_id, question.position, answer)
        #validateに引っかかったらnewに戻る
        answer_objects << answer_object
        unless answer_object.valid?
          @err = true
        end
      end
      @answers << answer_objects  #質問単位の回答を格納
    end
    #回答者のvalidateチェック（引っかかったらnewに戻る）
    if @err || !( @respondent.valid? )
      if @err
        flash.now[:notice]  = "文字数が多すぎます"
      end
      render :action => "new", :id => @questionnaire.id
      return
    end

  end

  def new
    if params[:id]
      init_answer
      flash.now[:notice] = "このアンケートの期限は終了しています" unless @questionnaire.operation
    elsif !params[:id] || !@questionnaire
      flash.now[:notice] = "アンケートが指定されていません"
    end
  end

  private

  #アンケートを取得
  def get_questionnaire
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questions = Question.find(:all, :conditions=>["questionnaire_id=? and content is not null and question_choice_id <> 0", params[:id]], :order=>"position")
    rescue
      false
    end
  end

  #回答の初期化
  def init_answer
    get_questionnaire
    @answers = []
    @questions.each do | question |
      answer = []
      question_choices = question.question_choices.find(:all, :conditions => ["content is not null"], :order => "position")
      if !question_choices.blank? && question_choices[0][:format] == QuestionChoice::CHECKBOX
        question_choices.each do | question_choice |
          answer << QuestionAnswer.new
        end
      else
        answer << QuestionAnswer.new
      end
      @answers << answer
    end
  end

  #新しいQuestionAnswerオブジェクトを作成
  def new_answer_object(question_id, question_choice_id, question_position, answer)
     answer_object = QuestionAnswer.new(:question_id=>question_id,
                                        :question_choice_id=>question_choice_id,
                                        :question_position=>question_position,
                                        :answer=>answer)
     return answer_object
  end

end
