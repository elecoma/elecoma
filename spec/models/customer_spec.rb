# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Customer do
  fixtures :customers, :zips, :constants
  fixtures :prefectures

  before(:each) do
    @customer = customers :valid_signup

    @customer_no_mail = Customer.new
    @customer_no_mail.family_name = "test"
    @customer_no_mail.first_name = "test"
    @customer_no_mail.family_name_kana = "test"
    @customer_no_mail.first_name_kana = "test"
    @customer_no_mail.email = "hoge_test"

    @customer_same_mail = Customer.new(@customer.attributes)
  end

  it "should be valid" do
    @customer.should be_valid
  end

  it "should not be valid" do
    @customer_second = Customer.new
    @customer_second.should_not be_valid
    @customer_no_mail.should_not be_valid
    @customer_same_mail.should_not be_valid
  end

  it "パスワードが再発行される場合" do
    old_password = @customer.password
    @customer.regenerate_password!
    @customer.password.should_not be_nil
    @customer.password.should_not == old_password
  end

  it "姓: 必須" do
    @customer.family_name = nil
    @customer.should_not be_valid
  end

  it "名: 必須" do
    @customer.first_name = nil
    @customer.should_not be_valid
  end

  it "姓(カナ): 必須" do
    @customer.family_name_kana = nil
    @customer.should_not be_valid
  end

  it "名(カナ): 必須" do
    @customer.first_name_kana = nil
    @customer.should_not be_valid
  end

  it "姓(カナ): カタカナのみ" do
    @customer.family_name_kana = 'ー'
    @customer.should be_valid
    @customer.family_name_kana = 'あああ'
    @customer.should_not be_valid
    @customer.family_name_kana = 'aaa'
    @customer.should_not be_valid
    @customer.family_name_kana = '999222'
    @customer.should_not be_valid
  end

  it "名(カナ): カタカナのみ" do
    @customer.first_name_kana = 'ー'
    @customer.should be_valid
    @customer.first_name_kana = 'いいい'
    @customer.should_not be_valid
    @customer.first_name_kana = 'iii'
    @customer.should_not be_valid
    @customer.first_name_kana = '999222'
    @customer.should_not be_valid
  end

  it "郵便番号1: 必須" do
    @customer.zipcode01 = nil
    @customer.should_not be_valid
  end

  it "郵便番号2: 必須" do
    @customer.zipcode02 = nil
    @customer.should_not be_valid
  end

  it "郵便番号1: 数字のみ" do
    @customer.zipcode01 = 'あ'
    @customer.should_not be_valid
  end

  it "郵便番号2: 数字のみ" do
    @customer.zipcode02 = 'い'
    @customer.should_not be_valid
  end

  it "郵便番号1: 3 文字固定" do
    @customer.zipcode01 = '12'
    @customer.should_not be_valid
    @customer.zipcode01 = '123'
    @customer.should be_valid
    @customer.zipcode01 = '1234'
    @customer.should_not be_valid
  end

  it "郵便番号2: 4 文字固定" do
    @customer.zipcode02 = '123'
    @customer.should_not be_valid
    @customer.zipcode02 = '1234'
    @customer.should be_valid
    @customer.zipcode02 = '12345'
    @customer.should_not be_valid
  end

  it "都道府県: 必須" do
    @customer.prefecture_id = nil
    @customer.should_not be_valid
  end

  it "都道府県: 範囲外" do
    @customer.prefecture_id = 48
    @customer.should_not be_valid
  end

  it "住所1: 必須" do
    @customer.address_city = nil
    @customer.should_not be_valid
  end

  it "住所2: 必須" do
    @customer.address_detail = nil
    @customer.should_not be_valid
  end

  it "メールアドレス: 必須" do
    @customer.email = nil
    @customer.should_not be_valid
  end

  it "メールアドレス: フォーマット" do
    @customer.email = 'foo'
    @customer.should_not be_valid
  end

  it "携帯でんわメール" do
    @customer.mobile_carrier = Customer::NOT_MOBILE
    @customer.email = 'foo@docomo.ne.jp'
    @customer.should_not be_valid
  end

  it "携帯でんわメール" do
    @customer.mobile_carrier = Customer::DOCOMO
    @customer.email = 'foo@docomo.ne.jp'
    @customer.should be_valid
  end

  it "電話番号1: 必須" do
    @customer.tel01 = nil
    @customer.should_not be_valid
  end

  it "電話番号2: 必須" do
    @customer.tel02 = nil
    @customer.should_not be_valid
  end

  it "電話番号3: 必須" do
    @customer.tel03 = nil
    @customer.should_not be_valid
  end

  it "電話番号1: 数字のみ" do
    @customer.tel01 = 'abcd'
    @customer.should_not be_valid
  end

  it "電話番号2: 数字のみ" do
    @customer.tel02 = 'abcd'
    @customer.should_not be_valid
  end

  it "電話番号3: 数字のみ" do
    @customer.tel03 = 'abcd'
    @customer.should_not be_valid
  end

  it "電話番号1: 6 文字まで" do
    @customer.tel01 = '1234567'
    @customer.should_not be_valid
  end

  it "電話番号2: 6 文字まで" do
    @customer.tel02 = '1234567'
    @customer.should_not be_valid
  end

  it "電話番号3: 6 文字まで" do
    @customer.tel03 = '1234567'
    @customer.should_not be_valid
  end

  it "FAX 番号1: 任意" do
    @customer.fax01 = nil
    @customer.should be_valid
  end

  it "FAX 番号2: 任意" do
    @customer.fax02 = nil
    @customer.should be_valid
  end

  it "FAX 番号3: 任意" do
    @customer.fax03 = nil
    @customer.should be_valid
  end

  it "FAX 番号1: 数字のみ" do
    @customer.fax01 = 'abcd'
    @customer.should_not be_valid
  end

  it "FAX 番号2: 数字のみ" do
    @customer.fax02 = 'abcd'
    @customer.should_not be_valid
  end

  it "FAX 番号3: 数字のみ" do
    @customer.fax03 = 'abcd'
    @customer.should_not be_valid
  end

  it "FAX 番号1: 6 文字まで" do
    @customer.fax01 = '1234567'
    @customer.should_not be_valid
  end

  it "FAX 番号2: 6 文字まで" do
    @customer.fax02 = '1234567'
    @customer.should_not be_valid
  end

  it "FAX 番号3: 6 文字まで" do
    @customer.fax03 = '1234567'
    @customer.should_not be_valid
  end

  it "性別: 必須" do
    @customer.sex = nil
    @customer.should be_valid
  end

  it "性別: 男 or 女" do
    @customer.sex = System::MALE
    @customer.should be_valid
    @customer.sex = System::FEMALE
    @customer.should be_valid
    @customer.sex = System::MALE + System::FEMALE
    @customer.should_not be_valid
  end

  it "職業: 任意" do
    @customer.occupation_id = nil
    @customer.should be_valid
  end

  it "生年月日: 任意" do
    @customer.birthday = nil
    @customer.should be_valid
  end


  it "パスワード: 必須" do
    @customer.password = nil
    @customer.should_not be_valid
  end

  it "パスワード: 4 文字以上" do
    @customer.password = 'abc'
    @customer.should_not be_valid
    @customer.password = 'abcd'
    @customer.should be_valid
    @customer.password = '123456789a'
    @customer.should be_valid
    @customer.password = '123456789ab'
    @customer.should be_valid
  end

  it "メールマガジン送付: 必須" do
    @customer.receive_mailmagazine = nil
    @customer.should_not be_valid
  end
  

  it "メールアドレスは他の会員と同じではいけない" do
    customer1 = customers :valid_signup
    customer2 = Customer.new(customer1.attributes)
    customer1.should be_valid
    customer2.should_not be_valid
    customer2.email_confirm = customer1.email
    customer2.should have_at_most(1).errors_on(:email)
    customer2.email = "aaaa@example.com"
    customer2.should have_at_most(0).errors_on(:email)

#    customer2.should be_valid
  end

  it "メールアドレスは退会者とは同じで良い" do
    customer1 = customers :withdrawn_customer
    customer2 = Customer.new(:email=>customer1.email)
    customer2.email_confirm = customer1.email
    customer2.should have_at_most(0).errors_on(:email)
  end

  it "メールアドレスは非会員とは同じで良い" do
    customer1 = customers :nonmember_customer
    customer1.valid?
    customer2 = Customer.new(:email=>customer1.email)
    customer2.email_confirm = customer1.email
    customer2.should have_at_most(0).errors_on(:email)
  end

  it "PC からの登録では携帯電話のメールアドレスは不可" do
    customer = customers :valid_signup
    customer.mobile_carrier == Customer::NOT_MOBILE
    customer.should be_valid
    customer.email = 'test@docomo.ne.jp'
    customer.should_not be_valid
    customer.email = 'test@ezweb.ne.jp'
    customer.should_not be_valid
    customer.email = 'test@softbank.ne.jp'
    customer.should_not be_valid
  end
  
  it "対象のカラム以外のエラーは無視する" do
    unvalid_costomer = Customer.new
    unvalid_costomer.should_not be_valid
    unvalid_costomer.email_confirm = 'test_target@example.com'
    unvalid_costomer.password_confirm = "password"
    unvalid_costomer.target_columns = []
    unvalid_costomer.should be_valid
    columns = ["first_name","tel01"]
    unvalid_costomer.target_columns = columns
    unvalid_costomer.should_not be_valid
    after_columns = []
    unvalid_costomer.errors.each do |i,j|
      after_columns << i
    end
    after_columns.should =~ columns
  end
  
  it "性別の名称" do
    customer = customers :valid_signup
    customer.sex = System::MALE
    customer.sex_view.should == System::SEX_NAMES[System::MALE]
  end

  it "メールマガジン受け取りの名称" do
    customer = customers :valid_signup
    customer.receive_mailmagazine = Customer::HTML_MAIL
    customer.receive_mailmagazine_view.should == Customer::MAILMAGAZINE_NAMES[Customer::HTML_MAIL]
  end

  it "ブラックリストの名称" do
    customer = customers :valid_signup
    customer.black = Customer::ON
    customer.black_view.should == Customer::BLACK_NAMES[Customer::ON]
  end
  
  it "登録メール到着可能フラグの名称" do
    customer = customers :valid_signup
    customer.reachable = Customer::REACHE
    customer.reachable_view.should == Customer::REACHABLE_NAMES[Customer::REACHE]
  end

  # パスワード関連
  it "あるパスワードをエンコードした結果は常に同じになる" do
    Customer.encode_password("hoge").should == Customer.encode_password("hoge")
  end
  
  it "パスワードエンコードする" do
    password = 'hoge'
    Customer.encode_password(password).should == Digest::SHA1.hexdigest("change-me--#{password}--")
  end

  it "会員登録住所" do
    customer = customers :valid_signup
    basic_address = customer.basic_address
    basic_address.should be_frozen
  end

  it "メールアドレスとパスワードで検索" do
    expected = customers :valid_signup
    raw_password = 'obakenoq'
    expected.password.should == Customer.encode_password(raw_password)

    actual = Customer.find_by_email_and_password(expected.email, raw_password)
    actual.id.should == expected.id
    actual.password.should == Customer.encode_password(raw_password)
  end

  it "メールアドレスとパスワードで検索(退会者は対象外)" do
    customer = customers :valid_signup
    raw_password = 'obakenoq'
    customer.password.should == Customer.encode_password(raw_password)
    customer.activate = Customer::TEISHI
    customer.save
    Customer.find_by_email_and_password(customer.email, raw_password).should be_nil
  end

  it "メールアドレスとパスワードで検索(非会員は対象外)" do
    customer = customers :valid_signup
    raw_password = 'obakenoq'
    customer.password.should == Customer.encode_password(raw_password)
    customer.activate = Customer::HIKAIIN
    customer.email_confirm = customer.email
    customer.save
    Customer.find_by_email_and_password(customer.email, raw_password).should be_nil
  end

  it "パスワードを比較" do
    customer = customers :valid_signup
    raw_password = 'obakenoq'
    customer.password.should == Customer.encode_password(raw_password)

    customer.correct_password?(raw_password).should be_true
    customer.correct_password?(customer.password).should_not be_true
  end

  it "パスワードを設定" do
    customer = customers :valid_signup
    new_password = 'maskedrider'
    customer.set_password(new_password)
    customer.password.should == Customer.encode_password(new_password)
  end

  it "会員登録時のキーを取得" do
    customer = customers :valid_signup
    customer.activation_key.should be_nil
    customer.generate_activation_key!
    customer.activation_key.should == Digest::SHA1.hexdigest(customer.email.to_s+DateTime.new.to_s)
  end

  it "アクティベーション" do
    expected = customers :kari
    actual = Customer.activate_email(expected.activation_key)
    actual.id.should == expected.id
    actual.activation_key.should be_nil
    actual.activate.should == Customer::TOUROKU
  end
  
  it "携帯電話キャリアを取得する" do
    c = Customer.new
    c.set_mobile_carrier(nil).should == Customer::NOT_MOBILE
    c.set_mobile_carrier(Jpmobile::Mobile::Docomo.new(nil)).should == Customer::DOCOMO
    c.set_mobile_carrier(Jpmobile::Mobile::Au.new(nil)).should == Customer::AU
    c.set_mobile_carrier(Jpmobile::Mobile::Softbank.new(nil)).should == Customer::SOFTBANK
  end

  it "携帯電話キャリアが適していればtrue、そうでなければfalse" do
    c = Customer.new
    c.mobile_carrier = Customer::NOT_MOBILE
    c.same_mobile_carrier?(nil).should be_true
    c.same_mobile_carrier?(Jpmobile::Mobile::Docomo.new(nil)).should_not be_true

    c.mobile_carrier = Customer::DOCOMO
    c.same_mobile_carrier?(Jpmobile::Mobile::Docomo.new(nil)).should be_true
    c.same_mobile_carrier?(Jpmobile::Mobile::Au.new(nil)).should_not be_true
    
    c.mobile_carrier = Customer::AU
    c.same_mobile_carrier?(Jpmobile::Mobile::Au.new(nil)).should be_true
    c.same_mobile_carrier?(Jpmobile::Mobile::Softbank.new(nil)).should_not be_true

    c.mobile_carrier = Customer::SOFTBANK
    c.same_mobile_carrier?(Jpmobile::Mobile::Softbank.new(nil)).should be_true
    c.same_mobile_carrier?(Jpmobile::Mobile::Docomo.new(nil)).should_not be_true
  end
  
  it "郵便番号から住所を取ってくる" do
    address = Customer.new()
    zip = zips(:zip_test_id_1)
    address.zipcode01 = zip.zipcode01
    address.zipcode02 = zip.zipcode02
    address.update_address!
    address.prefecture_id.should == zip.prefecture_id
    address.address_city.should == zip.address_city
    address.address_detail.should == zip.address_details
  end
  
  it "remote_ipからクッキーの取得" do
    customer = customers :valid_signup
    customer.cookie.should be_nil
    customer.generate_cookie!('aaa')
    customer.cookie.should_not be_nil
  end
  
  it "名字と名前をつなぐ" do
    customer = Customer.new(:family_name => 'あああ', :first_name => 'いいい')
    customer.full_name.should == "あああ いいい"
  end
  
  #現状だとraw_password,email_confirm,password_confirmがblankだとエラー
  it "CSVアップロード" do
    max_id = Customer.maximum(:id)
    Customer.add_by_csv("#{RAILS_ROOT}/spec/csv/customer_csv_upload_for_spec.csv")
    max_id.should < Customer.maximum(:id)
  end

  #新規のcustomerを登録してしまうので最後にテストを実行する
  it "会員状態を退会にする" do
    customer = Customer.new()
    customer.withdraw.should be_true
    customer.activate == Customer::TEISHI
  end

  private
  #比較して違うのあったらそのカラムを返す
  def compare(act,ext)
    error_calums = Array.new
    keys = act.attributes.keys
    keys.each do |key|
     unless ((act[key].blank? && ext[key].blank?) or ["id","email","created_at","updated_at"].include?(key))
         error_calums << key if act.send(key) != ext.send(key)
     end
    end
    return error_calums
  end
  

end
