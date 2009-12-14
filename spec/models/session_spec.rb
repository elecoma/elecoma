require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Session do
  before(:each) do
    @session = Session.new
  end
  describe "validateチェック" do
    it "データが正しい" do
      @session.should be_valid
    end
  end
  describe "その他" do
    it "sessionsから古いセッション情報を削除" do
      Session.delete_all
      Session.count.should == 0
      old_time = DateTime.now - 1.day
      Session.create(:session_id=>"111111",:data=>"test1",:created_at=>old_time,:updated_at=>old_time)
      Session.create(:session_id=>"222222",:data=>"test2",:created_at=>old_time,:updated_at=>old_time)
      Session.create(:session_id=>"333333",:data=>"test3",:created_at=>old_time,:updated_at=>old_time)
      Session.create(:session_id=>"444444",:data=>"test4",:created_at=>DateTime.now,:updated_at=>DateTime.now)
      Session.count.should == 4
      #デフォルトで60分前のデータを削除
      Session.cleanup_session
      Session.count.should == 1

      Session.create(:session_id=>"555555",:data=>"test5",:created_at=>DateTime.now - 20.minute,:updated_at=>DateTime.now - 20.minute)
      Session.create(:session_id=>"666666",:data=>"test6",:created_at=>DateTime.now - 50.minute,:updated_at=>DateTime.now - 50.minute)
      Session.count.should == 3
      
      Session.cleanup_session(40)
      Session.count.should == 2
    end
  end  
end
