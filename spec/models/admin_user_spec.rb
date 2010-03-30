# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminUser do
  fixtures :admin_users, :authorities, :retailers
  before(:each) do
    @admin_user = admin_users(:login_admin_user)
  end

  describe "validateチェック" do
    before do
      @admin_user.password = "hoge"
    end

    it "ログイン名" do
      #ログイン名は必須
      @admin_user.login_id = "hoge"
      @admin_user.should be_valid
      @admin_user.login_id = nil
      @admin_user.should_not be_valid


      #16文字以上は失敗
      @admin_user.login_id = "a" * 15
      @admin_user.should be_valid
      @admin_user.login_id = "a" * 16
      @admin_user.should_not be_valid
      
      #2重登録は失敗
      AdminUser.new({:login_id=>"new", :password=>@admin_user.password,:authority_id => authorities(:auth01).id  }).should_not be_valid

      #半角英数字以外は失敗
      @admin_user.login_id = "abc102"
      @admin_user.should be_valid
      @admin_user.login_id = "abc//102"
      @admin_user.should_not be_valid
      @admin_user.login_id = "ABC１ー"
      @admin_user.should_not be_valid
    end

    it "パスワード" do
      #16文字以上は失敗
      @admin_user.password = "a" * 15
      @admin_user.should be_valid
      @admin_user.password = "a" * 16
      @admin_user.should_not be_valid
      
      #半角英数字以外は失敗
      @admin_user.password = "abc102"
      @admin_user.should be_valid
      @admin_user.password = "abc//102"
      @admin_user.should_not be_valid
      @admin_user.password = "ABC１ー"
      @admin_user.should_not be_valid
    end
  end

  describe "パスワードの暗号化" do
    it "パスワードが暗号化できている" do
      AdminUser.encode_password("hoge").should_not == "hoge"
    end

    it "入力されたパスワードを暗号化(新規作成の場合)" do
      admin_user = AdminUser.new({:name=>"zak", :login_id=>"gundam", :password=>"zak", :authority_id => authorities(:auth01).id, :retailer_id => 1 })
      admin_user.save
      AdminUser.find(:first, :conditions=>["login_id=?","gundam"]).password.should == AdminUser.encode_password("zak")
    end

    it "入力されたパスワードを暗号化(変更なし)" do
      password = @admin_user.password
      @admin_user.password = ""
      @admin_user.save.should == true
      AdminUser.find(@admin_user.id).password.should == password
    end

    it "入力されたパスワードを暗号化(変更あり)" do
      password = @admin_user.password
      @admin_user.password = "hyakushiki"
      @admin_user.save.should == true
      AdminUser.find(@admin_user.id).password.should == AdminUser.encode_password("hyakushiki")
    end
  end

  describe "ログインしたい管理者の特定" do
    it "管理者を取得できる" do
      AdminUser.find_by_login_id_and_password(@admin_user.login_id, "hoge").should == @admin_user
    end

    it "管理者を取得できない" do
      #ログインIDが存在しない
      AdminUser.find_by_login_id_and_password("gundam", @admin_user.password).should be_nil

      #passwordが存在しない
      AdminUser.find_by_login_id_and_password(@admin_user.login_id, "gundam").should be_nil

      #非稼働な管理ユーザー
      activity_false = admin_users(:load_by_admin_user_activity_false)
      AdminUser.find_by_login_id_and_password(activity_false.login_id, activity_false.password).should be_nil
    end
  end

  describe "販売元IDを追加" do
    it "販売元IDがないとvalidateに失敗する" do
      @admin_user.retailer_id = nil
      @admin_user.should_not be_valid
    end

    it "マスターショップかどうか判定" do 
      @admin_user.should be_master_shop
      not_master_retailer = admin_users(:admin17_retailer_id_is_fails)
      not_master_retailer.should_not be_master_shop
    end
  end
end
