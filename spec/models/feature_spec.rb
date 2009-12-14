require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Feature do
  before(:each) do
    @feature = Feature.new(:name=>"特集テストコード",:dir_name=>"test1$%",:feature_type=>Feature::PRODUCT,:permit=>true)
  end
  describe "validateチェック" do
    it "データがただしい" do
      @feature.should be_valid
    end
    it "特集名" do
      #必須チェック
      @feature.name = nil
      @feature.should_not be_valid
    end
    it "ディレクトリ" do
      #必須チェック
      @feature.dir_name = nil
      @feature.should_not be_valid      
      #フォーマット
      @feature.dir_name = "あ"
      @feature.should_not be_valid      
    end
  end
  describe "表示系" do
    it "公開／非公開表示" do
      @feature.permit_label.should == "公開"
      @feature.permit = false
      @feature.permit_label.should == "非公開"
    end
  end
end
