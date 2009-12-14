class Questionnaire < ActiveRecord::Base

  acts_as_paranoid

  has_many :questions, :dependent => :destroy, :validate => false
  has_many :questionnaire_answers

  validates_presence_of :name
  validates_presence_of :content

  QUESTION_COUNT = 6
  QUESTION_CHOICE_COUNT = 8
  
  def validate
    #質問項目のvalidate
   if questions.size == 0
      errors.add "dummy","質問がありません"
   else
      errors.add "dummy", "質問1がありません" if questions[0] && questions[0].position != 1
      questions.each_with_index do | question, index |
        errors.add "dummy", "質問#{question.position}の内容がありません" if question.content.nil?
        errors.add "dummy", "質問#{question.position}の内容は不正な値です" if !question.content.nil? && question.content.length > 100000

        #選択四肢のvalidate
        question.question_choices.each_with_index do | question_choice, choice_index |
          errors.add "dummy", "質問#{question.position}の質問形式が選択されていません" if !question_choice.format && choice_index == 0
          errors.add "dummy", "質問#{question.position}の選択肢1がありません" if choice_index == 0 && (question_choice.format == QuestionChoice::CHECKBOX || question_choice.format == QuestionChoice::RADIOBUTTON) && question_choice.content.blank? 
        end
      end
    end
  end

  def init_data
    self.operation = false
    QUESTION_COUNT.times do |question_idx|
      question = Question.new(:content=>nil, :position=>question_idx+1)
      QUESTION_CHOICE_COUNT.times do |choice_idx|
        question.question_choices << QuestionChoice.new(:content=>nil, :position=>choice_idx+1)
      end
      questions << question
    end
  end

  def get_show_questions_data
    questions_data = []
    QUESTION_COUNT.times do | question_idx |
      if question = questions.find(:first, :conditions=>["position = ?", question_idx+1])
        QUESTION_CHOICE_COUNT.times do | choice_idx |
          if question_choice = question.question_choices.find(:first, :conditions=>["position = ?", choice_idx+1])          #既存の選択肢があれば取得
            question.question_choices << question_choice
          else  #選択肢を新しく追加
            question.question_choices.build(:content => nil, :position=>choice_idx+1)
          end
        end

      else  #質問項目を新しく作る
        question = Question.new({:content => nil, :position => question_idx+1})

        #選択肢を新しく作る
        QUESTION_CHOICE_COUNT.times do | choice_idx |
          question.question_choices << QuestionChoice.new({:content => nil, :position => choice_idx+1, :format => nil})
        end
      end
      questions_data << question
    end
    return questions_data
  end

  def self.csv(id, count)
    questionnaire = self.find(id)
    header = get_csv_header(count)
    f = StringIO.new('', 'w')
    CSV::Writer.generate(f) do |writer|
      writer << header
      questionnaire.questionnaire_answers.each do | questionnaire_answer |
        row = questionnaire_answer.export_row
        questionnaire_answer.question_answers.each do |question_answer|
          row.concat(question_answer.export_row)
        end
        writer << row
      end
    end
    f.string
  end

  private

  def self.get_csv_header(count)
    header = ["アンケート回答ID",
              "回答者（姓）",
              "回答者（名）",
              "回答者（セイ）",
              "回答者（メイ）",
              "回答者ID",
              "郵便番号１",
              "郵便番号２",
              "都道府県名",
              "市町村名",
              "町域名",
              "電話番号１",
              "電話番号２",
              "電話番号３",
              "作成日",
              "メールアドレス"]
    
    count.times do | index |
      header += ["回答#{index+1}"]
    end
    header
  end

end
