require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SupplierSearchForm do
  fixtures :suppliers
  before(:each) do
    @search_form = SupplierSearchForm.new
  end
  describe "validateチェック" do
    it "データがただしい" do
      @search_form.should be_valid
    end
    it "仕入先ID（数字）" do
      @search_form.supplier_id = 123456
      @search_form.should be_valid
      @search_form.supplier_id = "abc"
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
    it "ファックス番号（数字）" do
      @search_form.fax_no = "abc"
      @search_form.should_not be_valid
      @search_form.fax_no = "0311110001"
      @search_form.should be_valid
    end
  end
end
