require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/suppliers/new" do 
  fixtures :admin_users, :suppliers

  before(:each) do  
    assigns[:supplier] = Supplier.new 
  end
  
  describe "販売元IDを新規登録時に追加する" do 
    it "メイン管理者" do 
      @admin_user = session[:admin_user] = admin_users(:load_by_admin_user_test_id_1)
    end

    it "メイン以外管理者" do 
      @admin_user = session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
    end

    after do 
      render 'admin/suppliers/new'
      response.should have_tag("input[name=?][value=?]", 'supplier[retailer_id]', @admin_user.retailer_id)      
    end
  end

end
