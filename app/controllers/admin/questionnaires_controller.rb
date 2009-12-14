class Admin::QuestionnairesController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_enquete
  QUESTION_COUNT = Questionnaire::QUESTION_COUNT
  QUESTION_CHOICE_COUNT = Questionnaire::QUESTION_CHOICE_COUNT

  new_action.before do
    @questionnaire.init_data
    @questions = @questionnaire.questions
  end

  create.before do
    #質問項目作成
    @questions = []
    QUESTION_COUNT.times do | question_idx |
        choice_id_name = "question#{question_idx}_choice0_format"
        question = Question.new(:content=>params[:questions]["#{question_idx}"],
                                :position=>question_idx+1,
                                :question_choice_id=>params[choice_id_name])
        question_copy = Question.new(:content=>params[:questions]["#{question_idx}"],
                                :position=>question_idx+1,
                                :question_choice_id=>params[choice_id_name])
        #回答選択肢作成
        QUESTION_CHOICE_COUNT.times do | choice_idx |
          #チェックボックスおよびラジオボタン時のみquestion_choice.contentセット
          content = ""
          if params[choice_id_name].to_i == QuestionChoice::CHECKBOX || params[choice_id_name].to_i == QuestionChoice::RADIOBUTTON
            content = params["question#{question_idx}_choice#{choice_idx}"]
          end
          question_choice = QuestionChoice.new(:content => content,
                                               :format => params["question#{question_idx}_choice0_format"],
                                               :position => choice_idx+1)
          question.question_choices << question_choice if choice_idx == 0 || (choice_idx > 0 && !question_choice.content.blank?)
          question_copy.question_choices << question_choice
        end
        @questions << question_copy
        @questionnaire.questions << question if !question.content.empty?
    end
  end

  edit.before do
    @questions = @questionnaire.get_show_questions_data
  end

  update.before do
    @id = params[:id]
    @old_questions = Question.find(:all, :conditions=>["questionnaire_id=?", @id])

    @questions = []
    #質問項目更新
    QUESTION_COUNT.times do | question_idx |
      choice_id_name = "question#{question_idx}_choice0_format"
      question = @questionnaire.questions.build(:content=>params[:questions]["#{question_idx}"],
                                                :position=>question_idx+1,
                                                :question_choice_id=>params[choice_id_name]) if !params[:questions]["#{question_idx}"].empty?
      question_copy = Question.new(:content=>params[:questions]["#{question_idx}"],
                                   :position=>question_idx+1,
                                   :question_choice_id=>params[choice_id_name])
      #質問選択肢更新
      QUESTION_CHOICE_COUNT.times do | choice_idx |
        #チェックボックスおよびラジオボタン時のみquestion_choice.contentセット
        content = ""
        if params[choice_id_name].to_i == QuestionChoice::CHECKBOX || params[choice_id_name].to_i == QuestionChoice::RADIOBUTTON
          content = params["question#{question_idx}_choice#{choice_idx}"]
        end        
        if question && choice_idx == 0 || (choice_idx > 0 && !content.empty? )
          question.question_choices.build(:content=>content,
                                          :format=>params["question#{question_idx}_choice0_format"],
                                          :position=>choice_idx+1)
        end
        question_choice = QuestionChoice.new(:content=>content,
                                             :format=>params["question#{question_idx}_choice0_format"],
                                             :position=>choice_idx+1)
        question_copy.question_choices << question_choice
      end

      @questions << question_copy
    end
  end

  update.after do
    Question.clear_questions(@old_questions)
  end

  [create, update].each do |action|
    action.wants.html do
      redirect_to :action => "index"
    end
  end

  def csv_download
    result = Questionnaire.csv(params[:id], QUESTION_COUNT)
    filename = "questionnaire#{params[:id]}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => Iconv.conv('cp932', 'UTF-8', result)
  end

end
