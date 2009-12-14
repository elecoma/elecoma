require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Zip do
  fixtures :zips
  before(:each) do
    @zip = Zip.new
  end
  describe "validateチェック" do
    it "should be valid" do
      @zip.should be_valid
    end  
  end
  describe "その他" do
    it "郵便番号から住所検索" do
      Zip.find_by_zipcode('100','0001').should be_nil
      Zip.find_by_zipcode('907','1751').attributes.should == zips(:zip_rito_1).attributes
    end
    it "CSVインポート-住所インポート" do
      pending("インポートに時間がかかるため外しておく")
      Zip.delete_all
      Zip.import_address
      Zip.count.should > 100000
    end
    it "CSVインポート-企業インポート" do
      pending("インポートに時間がかかるため外しておく")
      Zip.delete_all
      Zip.import_office
      Zip.count.should > 10000
    end
    it "CSVインポート" do
      pending("インポートに時間がかかるため外しておく")
      Zip.import
      Zip.count.should > 100000
    end
  end

end
