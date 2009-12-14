require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MobileDevice do
  fixtures :mobile_devices

  before(:each) do
    #@mobile_device = mobile_devices(:one)
    @mobile_device = MobileDevice.find_by_id(1)
  end

  describe "validateチェック" do
    it "データが正しい場合" do
      @mobile_device.should be_valid
    end
    it "キャリアID" do
      #必須チェック
      @mobile_device.mobile_carrier_id = nil
      @mobile_device.should_not be_valid
    end
    it "端末機種名" do
      #必須チェック
      @mobile_device.device_name = nil
      @mobile_device.should_not be_valid
      #重複不可チェック
      MobileDevice.new(:mobile_carrier_id=>@mobile_device.mobile_carrier_id,:device_name=>@mobile_device.device_name,
      :user_agent=>"DoCoMo/2.0 P903i",:width=>232,:height=>640).should_not be_valid
    end
    it "ユーザーエージェント" do
      #必須チェック
      @mobile_device.user_agent = nil
      @mobile_device.should_not be_valid
      #フォーマットチェック
      @mobile_device.user_agent = "ドコモ"
      @mobile_device.should_not be_valid
    end
    it "画面サイズ（横）" do
      #必須チェック
      @mobile_device.width = nil
      @mobile_device.should_not be_valid
      #数字
      @mobile_device.width = "width"
      @mobile_device.should_not be_valid
    end
    it "画面サイズ（縦）" do
      #必須チェック
      @mobile_device.height = nil
      @mobile_device.should_not be_valid
      #数字
      @mobile_device.height = "height"
      @mobile_device.should_not be_valid
    end
  end
  
  describe "ユーザーエージェント名" do
    it "ユーザーエージェント名に「%」が付いている" do
      user_agent = "DoCoMo/2.0 P903i"
      @mobile_device = MobileDevice.new(:mobile_carrier_id=>@mobile_device.mobile_carrier_id,:device_name=>"P903i",
        :user_agent=>user_agent,:width=>232,:height=>640)
      @mobile_device.save
      @mobile_device.user_agent.should == user_agent << "%"
    end
    it "ユーザーエージェント名に「%」を除く" do
      @mobile_device.remove_precent
      @mobile_device.user_agent.index("%").should be_nil
    end  
  end
  
  describe "画面サイズ表示" do
    it "画面サイズ表示" do
      #VGA
      @mobile_device.width = 480
      @mobile_device.height= 640
      @mobile_device.human_size.should == "VGA"
      #QVGA
      @mobile_device.width = 240
      @mobile_device.height= 320
      @mobile_device.human_size.should == "QVGA"
      #その他
      @mobile_device.width = 232
      @mobile_device.height= 600
      @mobile_device.human_size.should == "232 x 600"
    end
  end
end
