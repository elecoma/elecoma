require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Kiyaku do
  fixtures :kiyakus
  
  before(:each) do
    @kiyaku = kiyakus(:kiyaku1)
  end
  describe "validateチェック" do
    it "データが正しい" do
      @kiyaku.should be_valid
    end
    it "規約タイトル " do
      #必須チェック
      @kiyaku.name  = ""
      @kiyaku.should_not be_valid
      #文字数（250以下）
      @kiyaku.name = 'x' * 250
      @kiyaku.should be_valid
      @kiyaku.name = 'x' * 251
      @kiyaku.should_not be_valid
    end
    
    it "規約内容" do
      #必須チェック
      @kiyaku.content  = ""
      @kiyaku.should_not be_valid
      #文字数（2000以下）
      @kiyaku.content = 'x' * 2000
      @kiyaku.should be_valid
      @kiyaku.content = 'x' * 2001
      @kiyaku.should_not be_valid
    end    
  end
end
