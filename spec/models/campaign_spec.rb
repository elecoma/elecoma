require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Campaign do
  fixtures :campaigns,:campaigns_customers,:customers,:products,:product_styles
  
  before(:each) do
    #商品コードなし
    @campaign_entry = campaigns(:campaign_entry)
    #商品コードあり
    @campaign_product = campaigns(:campaign_product)
  end

  describe "validateチェック" do
    it "データが正しい場合" do
      @campaign_entry.should be_valid
      @campaign_product.should be_valid
    end
    
    it "キャンペーン名" do
      #必須
      @campaign_entry.name = nil
      @campaign_entry.should_not be_valid
      #文字数(30文字以内)
      @campaign_entry.name = "あ" * 30
      @campaign_entry.should be_valid
      @campaign_entry.name = "あ" * 31
      @campaign_entry.should_not be_valid
    end
    
    it "ディレクトリ名" do
      #必須
      @campaign_entry.dir_name = nil
      @campaign_entry.should_not be_valid
      #文字数（30文字以内）
      @campaign_entry.dir_name = "a" * 30
      @campaign_entry.should be_valid
      @campaign_entry.dir_name = "a" * 31
      @campaign_entry.should_not be_valid
      #フォーマット
      @campaign_entry.dir_name = "テストコード"
      @campaign_entry.should_not be_valid
      #重複
      Campaign.new(:name=>@campaign_entry.name,:dir_name=>@campaign_entry.dir_name,:opened_at=>@campaign_entry.opened_at,
      :closed_at=>@campaign_entry.closed_at).should_not be_valid 
      @campaign_entry.should_not be_valid
    end
    
    it "公開開始終了日時" do
      #必須チェック
      Campaign.new(:name=>@campaign_entry.name,:dir_name=>"test").should_not be_valid
      
      #前後チェック
      @campaign_entry.opened_at = DateTime.now + 3.years
      @campaign_entry.closed_at = DateTime.now
      @campaign_entry.should_not be_valid
    end

    it "商品" do
      #商品ID重複チェック
      Campaign.new(:name=>@campaign_product.name,:dir_name=>"test",:opened_at=>@campaign_product.opened_at,
      :closed_at=>@campaign_product.closed_at,:product_id=>@campaign_product.product_id,
      :product_id=>@campaign_product.product_id).should_not be_valid      
      #商品コード英数字チェック
      @campaign_product.product_id = "test"
      @campaign_product.should_not be_valid
      @campaign_product.product_id = "１"
      @campaign_product.should_not be_valid
      #指定された商品コードを持つ商品がない
      @campaign_product.product_id = "0"
      @campaign_product.should_not be_valid
    end
  end

  describe "公開期間中かをチェック" do
    it "公開期間中かをチェック" do
      #公開期間外
      @campaign_entry.opened_at = DateTime.now + 3.years
      @campaign_entry.closed_at = DateTime.now + 3.years + 6.months
      @campaign_entry.check_term.should be_false
      #公開期間内
      @campaign_entry.opened_at = DateTime.now - 1.years
      @campaign_entry.closed_at = DateTime.now + 3.years
      @campaign_entry.check_term.should be_true
      #本日の時間
      now = DateTime.now
      @campaign_entry.opened_at = DateTime.new(now.year, now.month, now.day, 0, 0, 0, Rational(9, 24))
      @campaign_entry.closed_at = DateTime.new(now.year, now.month, now.day, 23, 59, 0, Rational(9, 24))
      @campaign_entry.check_term.should be_true  
    end
  end

  describe "申込人数をオーバーしているかをチェック" do
    it "申込人数をオーバーしているかをチェック" do
      #最大申し込み人数と申し込み人数が設定されていない
      @campaign_entry.check_max_application_number.should be_true
      #最大申し込み人数と申し込み人数が設定されているが申し込み人数が設定されていない
      @campaign_product.check_max_application_number.should be_true
      #最大申し込み人数と申し込み人数が設定されている、かつ、申し込み人数が最大申し込み人数に未満
      @campaign_product.application_count = 9
      @campaign_product.check_max_application_number.should be_true
      #最大申し込み人数と申し込み人数が設定されている、かつ、申し込み人数が最大申し込み人数以上に達する
      @campaign_product.application_count = 10
      @campaign_product.check_max_application_number.should be_false
    end
  end

  describe "重複申込に引っかかっているかをチェック" do
    it "重複申込に引っかかっているかをチェック" do
      #重複申し込み制御が設定されてない
      @campaign_entry.duplicated?(customers(:login_customer1)).should be_false
      #重複申し込み制御が設定されている、かつ、キャンペーンカスタマテーブルに該当顧客が存在しない
      @campaign_product.duplicated?(Customer.new(:id=>100)).should be_false
      #重複申し込み制御が設定されている、かつ、キャンペーンカスタマテーブルに該当顧客が存在
      @campaign_product.duplicated?(customers(:login_customer1)).should be_true
    end
  end
end
