require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Shop do
  fixtures :shops ,:prefectures
  before(:each) do
    @shop = shops :load_by_shop_test_id_1
  end
  
  describe"validateチェック" do
    it "should be_valid" do
      @shop.should be_valid
    end
    
    it "会社名 50 文字まで" do
      @shop.corp_name = 'x' * 50
      @shop.should be_valid
      @shop.corp_name = 'x' * 51
      @shop.should_not be_valid
    end
    
    it "会社名(カナ) 50 文字まで" do
      @shop.corp_name_kana = 'ア' * 50
      @shop.should be_valid
      @shop.corp_name_kana = 'ア' * 51
      @shop.should_not be_valid
    end
    
    it "会社名(カナ) カタカナのみ" do
      @shop.corp_name_kana = 'ア'
      @shop.should be_valid
      @shop.corp_name_kana = 'あ'
      @shop.should_not be_valid
    end
    
    it "店名: 必須" do
      @shop.name = ""
      @shop.should_not be_valid
    end
    
    it "店名 50 文字まで" do
      @shop.name = 'x' * 50
      @shop.should be_valid
      @shop.name = 'x' * 51
      @shop.should_not be_valid
    end
    
    it "店名(カナ) 50 文字まで" do
      @shop.name_kana = 'ア' * 50
      @shop.should be_valid
      @shop.name_kana = 'ア' * 51
      @shop.should_not be_valid
    end
    
    it "店名(カナ) カタカナのみ" do
      @shop.name_kana = 'ア'
      @shop.should be_valid
      @shop.name_kana = 'あ'
      @shop.should_not be_valid
    end
    
    it "郵便番号前半: 必須" do
      @shop.zipcode01 = ""
      @shop.should_not be_valid
    end
    
    it "郵便番号前半  数字のみ" do
      @shop.zipcode01 = '123'
      @shop.should be_valid
      @shop.zipcode01 = 'abc'
      @shop.should_not be_valid
    end
    
    it "郵便番号前半 3 文字まで" do
      @shop.zipcode01 = '123'
      @shop.should be_valid
      @shop.zipcode01 = '1234'
      @shop.should_not be_valid
    end
    
    
    it "郵便番号後半: 必須" do
      @shop.zipcode02 = ""
      @shop.should_not be_valid
    end
    
    it " 郵便番号前半  数字のみ" do
      @shop.zipcode02 = '1234'
      @shop.should be_valid
      @shop.zipcode02 = 'abcd'
      @shop.should_not be_valid
    end
    
    it "郵便番号後半 4 文字まで" do
      @shop.zipcode02 = '4567'
      @shop.should be_valid
      @shop.zipcode02 = '45678'
      @shop.should_not be_valid
    end
    
    it "都道府県 : 必須" do
      @shop.prefecture_id = ""
      @shop.should_not be_valid
    end
    
    it "都道府県 : 範囲" do
      @shop.prefecture_id = 0
      @shop.should_not be_valid
       (1..47).each do |i|
        @shop.prefecture_id = i
        @shop.should be_valid
      end
      @shop.prefecture_id = 48
      @shop.should_not be_valid
    end
    
    it "市区町村名 : 必須" do
      @shop.address_city = ""
      @shop.should_not be_valid
    end
    
    it "市区町村名 50 文字まで" do
      @shop.address_city = 'x' * 50
      @shop.should be_valid
      @shop.address_city = 'x' * 51
      @shop.should_not be_valid
    end
    
    it "番地・ビル名 : 必須" do
      @shop.address_details = ""
      @shop.should_not be_valid
    end
    
    it "番地・ビル名 50 文字まで" do
      @shop.address_details = 'x' * 50
      @shop.should be_valid
      @shop.address_details = 'x' * 51
      @shop.should_not be_valid
    end
    
    it "店舗営業時間 50 文字まで" do
      @shop.businesstime = 'x' * 50
      @shop.should be_valid
      @shop.businesstime = 'x' * 51
      @shop.should_not be_valid
    end
    
    it "TEL01, 02, 03 3-4文字まで" do
      @shop.tel01 = '1' * 3
      @shop.tel02 = '1' * 4
      @shop.tel03 = '1' * 4
      @shop.should be_valid
      @shop.tel01 = '11111'
      @shop.tel02 = '111111'
      @shop.tel03 = '111111'
      @shop.should_not be_valid
    end
    
    it "TEL01, 02, 03 半角数字のみ" do
      @shop.tel01 = '1'
      @shop.tel02 = '1'
      @shop.tel03 = '1'
      @shop.should be_valid
      @shop.tel01 = 'a'
      @shop.tel02 = 'a'
      @shop.tel03 = 'a'
      @shop.should_not be_valid
    end
    
    it "FAX01, 02, 03 3-4 文字まで" do
      @shop.fax01 = '1' * 3
      @shop.fax02 = '1' * 4
      @shop.fax03 = '1' * 4
      @shop.should be_valid
      @shop.fax01 = '1' * 4
      @shop.fax02 = '1' * 5
      @shop.fax02 = '1' * 5
      @shop.should_not be_valid
    end
    
    it "FAX01, 02, 03 半角数字のみ" do
      @shop.fax01 = '1'
      @shop.fax02 = '1'
      @shop.fax03 = '1'
      @shop.should be_valid
      @shop.fax01 = 'a'
      @shop.fax02 = 'a'
      @shop.fax03 = 'a'
      @shop.should_not be_valid
    end
    
    it "注文受付メールアドレス : 必須" do
      @shop.mail_shop = ""
      @shop.should_not be_valid
    end
    
    it "注文受付メールアドレス フォーマット" do
      @shop.mail_shop = 'foo@example.com'
      @shop.should be_valid
      @shop.mail_shop = 'foo.bar@example.com'
      @shop.should be_valid
      @shop.mail_shop = 'foo+bar@example.com'
      @shop.should be_valid
      @shop.mail_shop = 'foo@example'
      @shop.should_not be_valid
      @shop.mail_shop = 'foo@example.'
      @shop.should_not be_valid
      @shop.mail_shop = 'foo@.com'
      @shop.should_not be_valid
      @shop.mail_shop = 'foo'
      @shop.should_not be_valid
      @shop.mail_shop = 'foo@'
      @shop.should_not be_valid
      @shop.mail_shop = '@example.com'
      @shop.should_not be_valid
    end
    
    it "注文受付メールアドレス 50 文字まで" do
      suffix = '@example.com'
      name = 'x' * (50 - suffix.size)
      email = name + suffix
      email.size.should == 50
      @shop.mail_shop = email
      @shop.should be_valid
      @shop.mail_shop = 'x'+email
      @shop.should_not be_valid
    end
    
    it "問合せ受付メールアドレス : 必須" do
      @shop.mail_faq = ""
      @shop.should_not be_valid
    end
    
    it "問合せ受付メールアドレス フォーマット" do
      @shop.mail_faq = 'foo@example.com'
      @shop.should be_valid
      @shop.mail_faq = 'foo.bar@example.com'
      @shop.should be_valid
      @shop.mail_faq = 'foo+bar@example.com'
      @shop.should be_valid
      @shop.mail_faq = 'foo@example'
      @shop.should_not be_valid
      @shop.mail_faq = 'foo@example.'
      @shop.should_not be_valid
      @shop.mail_faq = 'foo@.com'
      @shop.should_not be_valid
      @shop.mail_faq = 'foo'
      @shop.should_not be_valid
      @shop.mail_faq = 'foo@'
      @shop.should_not be_valid
      @shop.mail_faq = '@example.com'
      @shop.should_not be_valid
    end
    
    it "問合せ受付メールアドレス 50 文字まで" do
      suffix = '@example.com'
      name = 'x' * (50 - suffix.size)
      email = name + suffix
      email.size.should == 50
      @shop.mail_faq = email
      @shop.should be_valid
      @shop.mail_faq = 'x'+email
      @shop.should_not be_valid
    end
    
    it "メール送信元メールアドレス : 必須" do
      @shop.mail_sender = ""
      @shop.should_not be_valid
    end
    
    it "メール送信元メールアドレス フォーマット" do
      @shop.mail_sender = 'foo@example.com'
      @shop.should be_valid
      @shop.mail_sender = 'foo.bar@example.com'
      @shop.should be_valid
      @shop.mail_sender = 'foo+bar@example.com'
      @shop.should be_valid
      @shop.mail_sender = 'foo@example'
      @shop.should_not be_valid
      @shop.mail_sender = 'foo@example.'
      @shop.should_not be_valid
      @shop.mail_sender = 'foo@.com'
      @shop.should_not be_valid
      @shop.mail_sender = 'foo'
      @shop.should_not be_valid
      @shop.mail_sender = 'foo@'
      @shop.should_not be_valid
      @shop.mail_sender = '@example.com'
      @shop.should_not be_valid
    end
    
    it "メール送信元メールアドレス 50 文字まで" do
      suffix = '@example.com'
      name = 'x' * (50 - suffix.size)
      email = name + suffix
      email.size.should == 50
      @shop.mail_sender = email
      @shop.should be_valid
      @shop.mail_sender = 'x'+email
      @shop.should_not be_valid
    end
    
    it "管理者メールアドレス : 必須" do
      @shop.mail_admin = ""
      @shop.should_not be_valid
    end
    
    it "管理者メールアドレス フォーマット" do
      @shop.mail_admin = 'foo@example.com'
      @shop.should be_valid
      @shop.mail_admin = 'foo.bar@example.com'
      @shop.should be_valid
      @shop.mail_admin = 'foo+bar@example.com'
      @shop.should be_valid
      @shop.mail_admin = 'foo@example'
      @shop.should_not be_valid
      @shop.mail_admin = 'foo@example.'
      @shop.should_not be_valid
      @shop.mail_admin = 'foo@.com'
      @shop.should_not be_valid
      @shop.mail_admin = 'foo'
      @shop.should_not be_valid
      @shop.mail_admin = 'foo@'
      @shop.should_not be_valid
      @shop.mail_admin = '@example.com'
      @shop.should_not be_valid
    end
    
    it "管理者メールアドレス 50 文字まで" do
      suffix = '@example.com'
      name = 'x' * (50 - suffix.size)
      email = name + suffix
      email.size.should == 50
      @shop.mail_admin = email
      @shop.should be_valid
      @shop.mail_admin = 'x'+email
      @shop.should_not be_valid
    end
    
    it "取扱商品 99999 文字まで" do
      @shop.trade_item = 'x' * 99999
      @shop.should be_valid
      @shop.trade_item = 'x' * 100000
      @shop.should_not be_valid
    end
    
    it "店舗案内 99999 文字まで" do
      @shop.introduction = 'x' * 99999
      @shop.should be_valid
      @shop.introduction = 'x' * 100000
      @shop.should_not be_valid
    end
    
    it "複数のデータが登録できない" do
      @shop_second = Shop.new(@shop.attributes)
      @shop_second.should_not be_valid
    end
  end
  
  describe"表示系メソッド" do
    it "tel" do
      @shop.tel.should == @shop.tel01+'-'+@shop.tel02+'-'+@shop.tel03
    end
    
    it "fax" do
      @shop.fax.should == @shop.fax01+'-'+@shop.fax02+'-'+@shop.fax03
    end
    
    it "zipcode" do
      @shop.zipcode.should == @shop.zipcode01+'-'+@shop.zipcode02
    end
    
    it "address" do
      @shop.address.should == @shop.prefecture.name + @shop.address_city + @shop.address_details
    end
  end
  
end
