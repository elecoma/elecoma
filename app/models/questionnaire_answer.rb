class QuestionnaireAnswer < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :customers
  belongs_to :questionnaire
  has_many :question_answers

  validates_presence_of :customer_family_name
  validates_presence_of :customer_first_name
  validates_presence_of :customer_family_name_kana
  validates_presence_of :customer_first_name_kana
  validates_presence_of :address_city
  validates_presence_of :address_details
  validates_presence_of :tel01
  validates_presence_of :tel02
  validates_presence_of :tel03
  validates_presence_of :email
  validates_presence_of :zipcode01
  validates_presence_of :zipcode02
  
  validates_format_of :email, :with => /[^@]+@[^@\.]+\.[^@\.]+/
  validates_format_of :customer_family_name_kana, :with => System::KATAKANA_PATTERN
  validates_format_of :customer_first_name_kana, :with => System::KATAKANA_PATTERN
  validates_format_of :tel01, :with => /^[0-9]*$/, :message => "は数字です"
  validates_format_of :tel02, :with => /^[0-9]*$/, :message => "は数字です"
  validates_format_of :tel03, :with => /^[0-9]*$/, :message => "は数字です"
  validates_format_of :zipcode01, :with => /^(([0-9]{3})|)$/, :message => "は3桁の数字です"
  validates_format_of :zipcode02, :with => /^(([0-9]{4})|)$/, :message => "は4桁の数字です"

  validates_confirmation_of :email

  def export_row
    array = []
    columns = ["id", "customer_family_name", "customer_first_name", "customer_family_name_kana", "customer_first_name_kana", "customer_id",
               "zipcode01", "zipcode02", "prefecture_name", "address_city", "address_details", "tel01", "tel02", "tel03",
               "created_at", "email"]
    for column in columns
      value = self.send(column)
      case value
      when Time
        value = value.strftime('%Y-%m-%d %H:%M:%S')
      when Array
        value = value.join(',')
      end
      array << value
    end
    return array
  end

end
