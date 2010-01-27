require 'spec_helper'

describe StockHistory do
  fixtures :stock_histories
  before(:each) do
    @sh = stock_histories(:stock_in)
  end

  describe "validateチェック" do
    it "should be_valid" do
      @sh.should be_valid
    end
    it "備考" do
      @sh.comment = nil
      @sh.should_not be_valid
      #文字数（1000以下）
      @sh.comment = "a" * 10000
      @sh.should be_valid
      @sh.comment = "a" * 10001
      @sh.should_not be_valid
    end
    it "入庫数" do
      #入庫の場合、入庫数必須
      sh_in = StockHistory.new(:comment=>"test",:stock_type=>1)
      sh_in.should have(1).errors_on(:storaged_count)
      #在庫調整の場合、入庫調整数、販売調整数、不良調整数は非必須
      sh_m =  StockHistory.new(:comment=>"test",:stock_type=>2)
      sh_m.should be_valid
    end
  end
  describe "その他" do
    it "入庫かどうか" do
      sh_in = StockHistory.new(:comment=>"test",:stock_type=>1)
      sh_in.stock_in?.should be_true
      sh_m = StockHistory.new(:comment=>"test",:stock_type=>2)
      sh_m.stock_in?.should be_false
      sh = StockHistory.new
      sh.stock_in?.should be_false
    end
  end
  
end
