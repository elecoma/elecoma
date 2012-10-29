require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authority do
  fixtures :authorities,:admin_users,:functions,:authorities_functions

  before(:each) do
    @authority = authorities(:auth01)
  end

  describe "validateチェック" do
    it "権限名（入力される場合）" do
      @authority.should be_valid
    end
    it "権限名（入力されてない場合）" do
      @authority.name = nil
      @authority.should_not be_valid
    end
    it "権限名重複場合" do
      Authority.new(:name =>@authority.name).should_not be_valid
    end
  end
  
  describe "テーブル関連" do
    it "権限が削除されると複数の権限ファンクションも削除されること" do
      #権限削除前
      @authority.functions.should_not be_empty
      @authority.destroy
      #権限削除後
      @authority.functions.should be_empty
    end
    it "権限が作成されると選択した権限ファンクションも作成されること" do
      @authority = Authority.new(:name=>"テスト")
      select_funtions ={
        functions(:F100).id =>functions(:F100).name,
        functions(:F102).id =>functions(:F102).name,
        functions(:F103).id =>functions(:F103).name
      }
      @authority.save
      #権限ファンクションセット前
      @authority.functions.collect{|f| f.id}.should be_empty
      @authority.chang_functions(select_funtions)
      #権限ファンクションセット後
      @authority.functions.collect(&:id).sort.should == select_funtions.keys.sort
    end
  end
end
