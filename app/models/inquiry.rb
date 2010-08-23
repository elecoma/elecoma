class Inquiry < ActiveRecord::Base

  acts_as_paranoid
  TABLE_NAME_JP = "お問い合わせ"

  validates_presence_of :email
  validates_presence_of :body
  validates_presence_of :kind
  validates_presence_of :name

  #validates_format_of :email, :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)*[a-z]{2,})|)$/i
  validates_format_of :tel, :with => /^[0-9()-]*$/, :allow_nil => true, :message => "の書式が不正です"

  def validate
    # メールアドレスRFC準拠チェック
    if email && email =~ Customer::EMAIL_PATTERN
      m = TMail::Mail.new
      m.from = email
      if m.from.nil?
        errors.add :email, '(%s)は当サイトではご利用になれません。' % email
      end
    end
  end

  GOODS, ORDER, CLAIM, SEND, CAMPAIGN, RISAGASU, SITE, OTHER = 1, 2, 3, 4, 5, 6, 7, 8
  KIND_NAMES = {GOODS=>"商品について", ORDER=>"注文について", CLAIM=>"ご請求について",
              SEND=>"発送について", CAMPAIGN=>"キャンペーンについて", RISAGASU=>"K&Bスタイルについて",
              SITE=>"サイトについて", OTHER=>"その他"}

  def show_kind_name
    KIND_NAMES[self.kind]
  end

  def self.pc_kind_list
    [[KIND_NAMES[GOODS], GOODS],
     [KIND_NAMES[CLAIM], CLAIM],
     [KIND_NAMES[SEND], SEND],
     [KIND_NAMES[CAMPAIGN], CAMPAIGN],
     [KIND_NAMES[RISAGASU], RISAGASU],
     [KIND_NAMES[SITE], SITE],
     [KIND_NAMES[OTHER], OTHER]]
  end

  def self.mobile_kind_list
    [[KIND_NAMES[GOODS], GOODS],
     [KIND_NAMES[ORDER], ORDER],
     [KIND_NAMES[CLAIM], CLAIM],
     [KIND_NAMES[SEND], SEND],
     [KIND_NAMES[CAMPAIGN], CAMPAIGN],
     [KIND_NAMES[OTHER], OTHER]]
  end
end
