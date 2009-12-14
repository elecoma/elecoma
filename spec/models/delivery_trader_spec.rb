require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryTrader do
  fixtures :delivery_traders
  
  before(:each) do
    @delivery_trader = delivery_traders :witch
  end
  
  describe "validateチェック" do
    it "データがただしい" do
      @delivery_trader.should be_valid
    end
    
    it "配送業者名" do
      #必須
      @delivery_trader.name  = nil
      @delivery_trader.should_not be_valid
      #文字数（ 50文字以下）
      @delivery_trader.name = 'x' * 50
      @delivery_trader.should be_valid
      @delivery_trader.name = 'x' * 51
      @delivery_trader.should_not be_valid
    end
        
    it "配送業者 重複不可（更新時は自分の名前以外かぶっちゃダメ）" do
      @delivery_trader.name  = "ヤマト"
      @delivery_trader.should_not be_valid
    end
    it "配送業者 重複不可(新規登録時はほかのデータと名前かぶっちゃダメ）" do
      delivery_trader= DeliveryTrader.new(:name => "キキ",:url=>"")
      delivery_trader.should_not be_valid
    end
    
    it "URL" do
      #文字数（ 50文字以下）
      suffix = 'http://'
      name = 'x' * (50 - suffix.size)
      url= suffix +name
      url.size.should == 50
      @delivery_trader.url =url
      @delivery_trader.should be_valid
      @delivery_trader.url = url +"x"
      @delivery_trader.should_not be_valid
      #フォーマット
      @delivery_trader.url = 'http'
      @delivery_trader.should_not be_valid      
    end
  end
end
