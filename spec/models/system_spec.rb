require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe System do
  fixtures :systems
  before(:each) do
    @system = systems(:load_by_system_test_id_1)
  end
  describe "validateチェック" do
    it "データがただしい" do
      systems(:load_by_system_test_id_1).should be_valid
    end  
    it "複数のデータが登録できない" do
      system = System.new(@system.attributes)
      system.should_not be_valid
    end
  end
end
