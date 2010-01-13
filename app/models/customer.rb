# -*- coding: utf-8 -*-
require 'digest/sha1'

class Customer < ActiveRecord::Base

  acts_as_paranoid
  attr_accessor :email_confirm, :editting
  attr_accessor :raw_password, :password_confirm
  attr_accessor :email_user, :email_domain, :email_user_confirm
  attr_accessor :excepted
  belongs_to :prefecture
  belongs_to :occupation
  has_many :orders
  has_many :delivery_addresses
  has_many :carts, :order => "position"
  belongs_to :campaign_entry

  KARITOUROKU, TOUROKU, TEISHI, HIKAIIN = 1, 2, 3, 4
  ACTIVATE_NAMES = { KARITOUROKU => '仮登録', TOUROKU => '登録', TEISHI => '退会', HIKAIIN => '非会員' }
  TEXT_MAIL, HTML_MAIL, NO_MAIL = 1, 2, 0
  MAILMAGAZINE_NAMES = { HTML_MAIL => 'HTML メール', TEXT_MAIL => 'テキストメール', NO_MAIL => '希望しない' }
  ON, OFF = true, false
  BLACK_NAMES = {ON => "ON", OFF => "OFF"}
  REACHE, NOT_REACHE = true, false
  REACHABLE_NAMES = {REACHE => "到達可能", NOT_REACHE => "到達不可能"}
  #モバイルキャリア
  NOT_MOBILE, DOCOMO, AU, SOFTBANK = 0, 1, 2, 3
  DOMAIN_DOCOMO = 'docomo.ne.jp'
  DOMAIN_AU = 'ezweb.ne.jp'
  EMAIL_PATTERN = /^([^@]([\.\+_a-z0-9-]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))$/i

  attr_accessor :from_cart
  attr_accessor :target_columns
  attr_accessor :csv_input

  validates_presence_of :email

  validates_presence_of :family_name, :first_name

  validates_presence_of :family_name_kana, :first_name_kana
  validates_format_of :family_name_kana, :first_name_kana, :with => System::KATAKANA_PATTERN

  validates_presence_of :zipcode01, :zipcode02
  validates_numericality_of :zipcode01, :zipcode02, :allow_blank=>true
  validates_length_of :zipcode01, :is => 3, :allow_blank=>true
  validates_length_of :zipcode02, :is => 4, :allow_blank=>true

  validates_presence_of :prefecture_id
  validates_associated :prefecture

  validates_presence_of :address_city, :address_detail

  validates_presence_of :tel01, :tel02, :tel03
  validates_numericality_of :tel01, :tel02, :tel03, :allow_blank => true
  validates_length_of :tel01, :tel02, :tel03, :maximum => 6, :allow_blank => true

  validates_numericality_of :fax01, :fax02, :fax03, :allow_blank => true
  validates_length_of :fax01, :fax02, :fax03, :maximum => 6, :allow_blank => true

  validates_inclusion_of :sex, :in => [System::MALE, System::FEMALE], :allow_blank => true

  validates_presence_of :password, :unless => :new_record?
  validates_presence_of :raw_password, :if => :password_presence_check?
  validates_length_of :raw_password, :in => 4..10, :allow_blank => true
  validates_length_of :password, :minimum => 4, :allow_blank => true

  validates_presence_of :receive_mailmagazine, :unless => :from_cart

  def password_presence_check?
    #編集　CSVアップロード　非会員購入の場合、パスワード必須チェックを行わない
    new_record? && !csv_input && activate != HIKAIIN
  end

  def initialize(*)
    super
    self.receive_mailmagazine ||= HTML_MAIL
    self.sex ||= System::MALE
  end

  def before_validation
    unless email_domain.blank?
      self.email = '%s@%s' % [email_user, email_domain]
      self.email_confirm = '%s@%s' % [email_user_confirm, email_domain]
    end
  end

  def validate
    if email && email =~ EMAIL_PATTERN
      m = TMail::Mail.new
      m.from = email
      if m.from.nil?
        errors.add :email, '(%s)は当サイトではご利用になれません。' % email
      end
    end
    if activate != TEISHI && activate != HIKAIIN # 退会済みと非会員は対象外(顧客管理での編集時)
      str = 'email = :email and activate in (:activate)'
      str += ' and id <> :id' if id
      params = { :id => id, :email => email,
        :activate => [self.class::TOUROKU, self.class::KARITOUROKU] }
      if self.class.find(:first, :conditions => [str, params])
        errors.add :email, 'は、すでに登録されているメールアドレスです'
      end
    end
    # 顧客登録/編集の時だけ
    if editting
      # メールアドレス確認入力
      if email != email_confirm
        errors.add :email, 'が一致しません'
      end
      # パスワード確認入力
      if raw_password != password_confirm
        errors.add :password, 'が一致しません'
      end
    end
    # 非会員購入時のメールアドレス
    if activate == HIKAIIN
      # メールアドレス確認入力
      if email != email_confirm
        errors.add :email, 'が一致しません'
      end
    end

    # PC からの登録では携帯電話のメールアドレスは不可
    if mobile_carrier == NOT_MOBILE
      if email && (domain = email.split('@')[1])
        list = [DOMAIN_DOCOMO, DOMAIN_AU] +
          Constant.list(Constant::DOMAIN_SOFTBANK).map(&:value)
        if list.include?(domain)
          errors.add :email, 'は PC アドレスのみ登録可能です'
        end
      end
    end
    strip_errors
  end

  def validate_on_create
    errors.add :email, '(確認用)を入力してください' if email_confirm.blank? && !csv_input
    errors.add :password, '(確認用)を入力してください' if password_confirm.blank? && !csv_input && activate != HIKAIIN
  end

  def after_validation
    # パスワードを暗号化
    unless raw_password.blank?
      set_password(raw_password)
    end
  end

  def strip_errors
    # 対象のカラム以外のエラーは無視する
    if self.target_columns
      target_columns = self.target_columns.map(&:to_s)
      if target_columns.include?('email_user')
        target_columns << 'email'
      end
      if target_columns.include?('raw_password')
        target_columns << 'password'
      end
      e = errors.select{|k,_|target_columns.include?(k)}
      errors.clear
      e.each do |k,v|
        errors.add k, v
      end
    end
  end

  def sex_view
    System::SEX_NAMES[sex]
  end

  def receive_mailmagazine_view
    MAILMAGAZINE_NAMES[receive_mailmagazine]
  end

  def prefecture_name
    prefecture && prefecture.name
  end

  def occupation_name
    occupation && occupation.name
  end

  def black_view
    BLACK_NAMES[black]
  end

  def reachable_view
    REACHABLE_NAMES[reachable]
  end

  def regenerate_password!
    array = Array.new
    i = 0; while i < 8
      array << rand(62)
      i += 1
    end
    pass = array.pack("C*").tr("\x00-\x3d", "A-Za-z0-9")
    self.password = self.class.encode_password(pass)
    return pass
  end

  def self.encode_password(pass)
    Digest::SHA1.hexdigest("change-me--#{pass}--")
  end

  # 会員登録住所を得る。会員登録情報から生成されたお届け先は変更できないように凍結しておく。
  def basic_address
      DeliveryAddress.new(
        {
          :family_name      => family_name,
          :first_name       => first_name,
          :family_name_kana => family_name_kana,
          :first_name_kana  => first_name_kana,
          :prefecture_id   => prefecture_id,
          :zipcode01   => zipcode01,
          :zipcode02  => zipcode02,
          :address_city    => address_city,
          :address_detail  => address_detail,
          :tel01           => tel01,
          :tel02           => tel02,
          :tel03           => tel03
        }
      ).freeze
  end

  def self.find_by_email_and_password email, password
    find(:first, :conditions => [
      'email=? and password=? and activate in (?)',
      email, encode_password(password), [TOUROKU, KARITOUROKU]
    ])
  end

  def correct_password? raw_password
    password == self.class.encode_password(raw_password)
  end

  def set_password raw_password
    self.password = self.class.encode_password(raw_password)
  end

  def generate_activation_key!
    self.activation_key = Digest::SHA1.hexdigest(email.to_s+DateTime.new.to_s)
  end

  def self.activate_email key
    record = find_by_activation_key_and_activate(key, KARITOUROKU)
    return nil unless record
    record.activate = TOUROKU
    record.activation_key = nil
    record.reachable = true
    record.update_attributes(:activate=>TOUROKU, :activation_key=>nil, :reachable=>true)
    record
  end

  def set_mobile(mobile)
    set_mobile_carrier(mobile)
    mobile.nil? and return
    self.mobile_serial = mobile.ident_subscriber
    self.mobile_type = mobile.ident_device
  end

  def set_mobile_carrier name
    if name.nil?
      self.mobile_carrier = self.class::NOT_MOBILE
    else
      self.mobile_carrier = get_mobile_id_by_class(name)
    end
  end

  def same_mobile_carrier? name
    if name.nil?
      return mobile_carrier.to_i == self.class::NOT_MOBILE
    end
    mobile_carrier == get_mobile_id_by_class(name)
  end

  # 郵便番号から住所を取ってくる
  def update_address!(overwrite=true)
    return if zipcode01.blank? or zipcode02.blank?
    return unless zipcode01_changed? or zipcode02_changed?
    if overwrite ||
      (prefecture_id.blank? && address_city.blank? && address_detail.blank?) ||
      (!prefecture_id_changed? && !address_city_changed? && !address_detail_changed?)
    then
      zip = Zip.find_by_zipcode(zipcode01, zipcode02)
      if zip
        self.prefecture_id = zip.prefecture_id
        self.address_city = zip.address_city
        self.address_detail = zip.address_details
      end
    end
  end

  def generate_cookie!(addr)
    sha1 = Digest::SHA1.new
    sha1 << addr
    sha1 << DateTime.now.to_s
    sha1 << email
    self.cookie = sha1.hexdigest
  end

  def full_name
    "#{family_name} #{first_name}"
  end
  
  def full_name_kana
    "#{family_name_kana} #{first_name_kana}"
  end

  def tel_no
    "#{tel01}-#{tel02}-#{tel03}"
  end

  def self.get_symbols
    [
     :id,
     :zipcode01,
     :zipcode02,
     :tel01,
     :tel02,
     :tel03,
     :fax01,
     :fax02,
     :fax03,
     :sex,
     :age,
     :point,
     :occupation_id,
     :prefecture_id,
     :family_name,
     :first_name,
     :family_name_kana,
     :first_name_kana,
     :email,
#     :mobile_serial,
     :activation_key,
     :password,
     :address_city,
     :address_detail,
#     :login_id,
     :birthday,
     :activate,
     :receive_mailmagazine,
     :mobile_carrier,
     :black,
     :deleted_at,
#     :mobile_type,
#     :user_agent,
#     :corporate_name,
#     :corporate_name_kana,
#     :section_name,
#     :section_name_kana,
#     :contact_tel01,
#     :contact_tel02,
#     :contact_tel03,
#     :address_building,
     :reachable,
     :mail_delivery_count,
     :created_at,
     :updated_at
    ]
  end

  def self.field_names
    {
     :id => "id",
     :zipcode01 => "郵便番号(前半)",
     :zipcode02 => "郵便番号(後半)",
     :tel01 => "電話番号1",
     :tel02 => "電話番号2",
     :tel03 => "電話番号3",
     :fax01 => "FAX番号1",
     :fax02 => "FAX番号2",
     :fax03 => "FAX番号3",
     :sex => "性別",
     :age => "年齢",
     :point => "ポイント",
     :occupation_id => "職業ID",
     :prefecture_id => "都道府県ID",
     :family_name => "姓",
     :first_name => "名",
     :family_name_kana => "姓(カナ)",
     :first_name_kana => "名(カナ)",
     :email => "メールアドレス",
#     :mobile_serial => "携帯固有識別ID",
     :activation_key => "会員登録時のキー",
     :address_city => "住所(市町村)",
     :address_detail => "住所(番地・ビル名)",
#     :login_id => "ログインID",
     :birthday => "生年月日",
     :created_at => "作成日",
     :updated_at => "更新日",
     :activate => "会員状態",
     :receive_mailmagazine => "メールマガジン受信可否",
     :mobile_carrier => "携帯電話キャリア",
     :black => "ブラックリストフラグ",
     :password => "パスワード",
     :deleted_at => "削除日",
#     :mobile_type => "機種ID",
#     :user_agent => "ユーザーエージェント",
#     :corporate_name => "会社名",
#     :corporate_name_kana => "会社名カナ",
#     :section_name => "部署名",
#     :section_name_kana => "部署名カナ",
#     :contact_tel01 => "昼間連絡先電話番号1",
#     :contact_tel02 => "昼間連絡先電話番号2",
#     :contact_tel03 => "昼間連絡先電話番号3",
#     :address_building => "住所(建物)",
     :reachable => "登録メール到着可能フラグ",
     :mail_delivery_count => "メール送信回数"
    }
  end

  def withdraw
    self.activate = TEISHI
    self.cookie = nil
    self.save_without_validation
  end

  class << self
    def add_by_csv(file)
      line = 0
      Customer.transaction do
        CSV::Reader.parse(file) do |row|
          if line != 0
            customer = new_by_array(row)
            unless customer.save!
              return [line, false]
            end
          end
          line = line + 1
        end
      end
      [line - 1, true]
    end

    private

    def new_by_array(arr)
      arr.map! do | val |
        Iconv.conv('UTF-8', 'cp932', val)
      end
      #arr[0]が対応しているデータ存在する時、更新、存在しない時、新規作成
      unless !arr[0].blank? && customer = Customer.find_by_id(arr[0])
        customer = Customer.new
      end
      #CSVデータ設定
      set_data(customer,arr)
      #customer
      customer
    end
    #CSVデータ設定
    def set_data(customer,arr)
      #ダウンロードCSVファイルをEXCELで開く時、[010]が[10]になる対応
      customer.zipcode01 = arr[1].rjust(3, '0')
      customer.zipcode02 = arr[2].rjust(4, '0')
      customer.tel01 = arr[3]
      customer.tel02 = arr[4]
      customer.tel03 = arr[5]
      customer.fax01 = arr[6]
      customer.fax02 = arr[7]
      customer.fax03 = arr[8]
      customer.sex = System::SEX_NAMES.index arr[9]
      customer.age = arr[10]
      customer.point = arr[11]
      customer.occupation_id = arr[12]
      customer.prefecture_id = arr[13]
      customer.family_name = arr[14]
      customer.first_name = arr[15]
      customer.family_name_kana = arr[16]
      customer.first_name_kana = arr[17]
      customer.email = arr[18]
      customer.activation_key = arr[19]
      customer.password = arr[20]
      customer.address_city = arr[21]
      customer.address_detail = arr[22]
#      customer.login_id = arr[23]
      customer.birthday = arr[23]
      customer.activate = arr[24]
      customer.receive_mailmagazine = arr[25]
      customer.mobile_carrier = arr[26]
      customer.black = arr[27]
      customer.deleted_at = arr[28]
      customer.reachable = arr[29]
      customer.mail_delivery_count = arr[30]
      customer.created_at = arr[31]
      customer.updated_at = arr[32]
      customer.csv_input = true      
    end

  end

  private
  def get_mobile_id_by_class name
    case name
    when Jpmobile::Mobile::Docomo
      DOCOMO
    when Jpmobile::Mobile::Au
      AU
    when Jpmobile::Mobile::Softbank
      SOFTBANK
    else
      NOT_MOBILE
    end
  end



end

