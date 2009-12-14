require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailMagazineSearchForm do
  before(:each) do
    @mail_maga_search_form = MailMagazineSearchForm.new
  end
  describe "validateチェック" do
    it "データがただしい"  do
      @mail_maga_search_form.should be_valid
    end
    it "顧客ID（数字）" do
      @mail_maga_search_form.customer_id = 123456
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.customer_id = "abc"
      @mail_maga_search_form.should_not be_valid
    end
    it "顧客名（半角カタカナ）" do
      @mail_maga_search_form.customer_name_kana = "カタカナ"
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.customer_name_kana = "ｶﾀｶﾅ"
      @mail_maga_search_form.should_not be_valid
      @mail_maga_search_form.customer_name_kana = "漢字"
      @mail_maga_search_form.should_not be_valid
    end
    it "メールアドレス（英数字）" do
      @mail_maga_search_form.email = "abc"
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.email = "a_bc@email.com"
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.email = "あ"
      @mail_maga_search_form.should_not be_valid
    end
    it "電話番号（数字）" do
      @mail_maga_search_form.tel_no = "abc"
      @mail_maga_search_form.should_not be_valid
      @mail_maga_search_form.tel_no = 123
      @mail_maga_search_form.should be_valid
    end
    it "購入金額から（数字）" do
      @mail_maga_search_form.total_from = 2
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.total_from = "a"
      @mail_maga_search_form.should_not be_valid
    end
    it "購入金額まで（数字）" do
      @mail_maga_search_form.total_to = 2
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.total_to = "a"
      @mail_maga_search_form.should_not be_valid      
    end
    it "購入回数から（数字）" do
      @mail_maga_search_form.order_count_from = 2
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.order_count_from = "a"
      @mail_maga_search_form.should_not be_valid      
    end
    it "購入回数まで（数字）" do
      @mail_maga_search_form.order_count_to = 2
      @mail_maga_search_form.should be_valid
      @mail_maga_search_form.order_count_to = "a"
      @mail_maga_search_form.should_not be_valid      
    end    
  end
end
