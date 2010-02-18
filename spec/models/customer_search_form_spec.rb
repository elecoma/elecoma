require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CustomerSearchForm do
  fixtures :customers
  before(:each) do
    @search_form = CustomerSearchForm.new
  end
  describe "validateチェック" do
    it "データがただしい" do
      @search_form.should be_valid
    end
    it "顧客ID（数字）" do
      @search_form.customer_id = 123456
      @search_form.should be_valid
      @search_form.customer_id = "abc"
      @search_form.should_not be_valid
    end
    it "顧客名（半角カタカナ）" do
      @search_form.customer_name_kana = "カタカナ"
      @search_form.should be_valid
      @search_form.customer_name_kana = "ｶﾀｶﾅ"
      @search_form.should_not be_valid
      @search_form.customer_name_kana = "漢字"
      @search_form.should_not be_valid
    end
    it "メールアドレス（英数字）" do
      @search_form.email = "abc"
      @search_form.should be_valid
      @search_form.email = "a_bc@email.com"
      @search_form.should be_valid
      @search_form.email = "あ"
      @search_form.should_not be_valid
    end
    it "電話番号（数字）" do
      @search_form.tel_no = "abc"
      @search_form.should_not be_valid
      @search_form.tel_no = 123
      @search_form.should be_valid
    end
    it "購入金額から（数字）" do
      @search_form.total_down = 2
      @search_form.should be_valid
      @search_form.total_down = "a"
      @search_form.should_not be_valid
    end
    it "購入金額まで（数字）" do
      @search_form.total_up = 2
      @search_form.should be_valid
      @search_form.total_up = "a"
      @search_form.should_not be_valid      
    end
    it "購入回数から（数字）" do
      @search_form.order_count_down = 2
      @search_form.should be_valid
      @search_form.order_count_down = "a"
      @search_form.should_not be_valid      
    end
    it "購入回数まで（数字）" do
      @search_form.order_count_up = 2
      @search_form.should be_valid
      @search_form.order_count_up = "a"
      @search_form.should_not be_valid      
    end
    it "商品コード" do
      #非必須
      @search_form.product_code = nil
      @search_form.should be_valid
      #フォーマット
      @search_form.product_code = "ああ"
      @search_form.should_not be_valid
      @search_form.product_code = "PF001"
      @search_form.should be_valid 
    end

    it "(BUG Check): 商品コード検索" do
      @search_form.product_code = "TEST"
      CustomerSearchForm.get_sql_condition(@search_form) #before bug fix, raise error
    end
  end
  describe "その他" do
    it "CSVダウンロード" do
      #条件なしでダウンロード
      actual_titles,actual_datas = getCsv(CustomerSearchForm.csv({}))
      #タイトル
      act = actual_titles.sort
      ext = Customer.field_names.values.sort
      act.should == ext
      #データ内容
      ext_datas = convert(Customer.find(:all,:order => 'id'))
      actual_datas.should == ext_datas
    end
  end
#=============================================
  private
  #CSVダウンロードデータを比較用データに変換
  def getCsv(datas)
    
    #タイトル
    actual_titles = []
    #データ
    actual_datas = []
    datas.split("\n").each_with_index do |d,i|
      if i == 0
        actual_titles = d.split(/\s*,\s*/)
      else
        actual_datas << d.split(/\s*,\s*/)
      end
    end
    return actual_titles ,actual_datas
  end
  #fixturesデータをCSV形式に変換（比較用）
  def convert(customers)
    datas = []
    customers.each do |c|
      arr = []
      Customer.get_symbols.map do |sym|
        if [:sex].include?(sym)
          arr << (c.sex == System::MALE ? System::SEX_NAMES[System::MALE] : System::SEX_NAMES[System::FEMALE])
        elsif [:age].include?(sym)
          arr << (CustomerSearchForm.get_age(c.birthday).nil? ? "" : CustomerSearchForm.get_age(c.birthday).to_s)
        else
          arr << (c.send(sym).nil? ? "" : c.send(sym).to_s)
        end
      end
      datas << arr.join(",").split(",")
    end
    datas
  end
end
