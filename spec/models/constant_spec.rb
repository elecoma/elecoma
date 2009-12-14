require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Constant do
  fixtures :constants
  before(:each) do
    @constant = Constant.new
  end
  describe "validateチェック" do
    it "should be valid" do
      @constant.should be_valid
    end  
  end
  describe "その他" do
    it "キーで指定されたものを position 順に取得" do
      records = Constant.list(Constant::DOMAIN_SOFTBANK)
      position = 0
      records.each do | record |
        record.key.should == Constant::DOMAIN_SOFTBANK
        record.position.should >= position
        position = record.position
      end
    end
    
    it "2 要素タプルのリスト" do
      options = Constant.list_for_options(Constant::DOMAIN_SOFTBANK)
      list = Constant.list(Constant::DOMAIN_SOFTBANK)
      options.size.should == list.size
      options.each do | item |
        item.size.should == 2
      end
    end
  end
end
