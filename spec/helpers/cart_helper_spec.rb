require File.dirname(__FILE__) + '/../spec_helper'

describe CartHelper do
  fixtures :carts, :customers, :delivery_addresses, :prefectures
  before(:each) do
    @address = delivery_addresses(:optional_address)
  end  
  #Delete this example and add some real ones or delete this file
  it "should include the CartHelper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(CartHelper)
  end

  it "会員お届け先のラジオボタンを生成" do
    address = DeliveryAddress.new.freeze
    result_tag = "<input checked=\"checked\" class=\"radio_btn\" id=\"address_select_0\" name=\"address_select\" type=\"radio\" value=\"0\" />"
    helper.address_button(address).should == result_tag
  end

  it "追加お届け先のラジオボタンを生成" do
    result_tag = "<input class=\"radio_btn\" id=\"address_select_3\" name=\"address_select\" type=\"radio\" value=\"3\" />"
    helper.address_button(@address).should == result_tag
  end

  it "会員お届け先の表示" do
    address = DeliveryAddress.new.freeze
    result_text = '会員登録住所'
    helper.address_type_to_s(address).should == result_text
  end

  it "追加お届け先の表示" do
    result_text = '追加登録住所'
    helper.address_type_to_s(@address).should == result_text
  end

  it "お届け先住所を結合して表示" do
    result_text = "〒111-2222<br/>東京都 秋田市 1丁目<br/>田中　一郎"
    helper.address_detail(@address).should == result_text
  end

  it "追加お届け先の場合は変更リンクが生成されること" do
    result_tag = "<a href=\"/accounts/delivery_edit_popup/3\" class=\"delivery_edit\">変更</a>"
    helper.link_to_edit_address(@address).should == result_tag
  end

  it "会員お届け先の場合は変更リンクが生成されないこと" do
    address = DeliveryAddress.new.freeze
    result_tag = nil
    helper.link_to_edit_address(address).should == result_tag
  end

  it "追加お届け先の場合は削除リンクが生成されること" do
    result_tag = "<a href=\"/accounts/delivery_destroy/3?backurl=%2Fcart%2Fshipping\" onclick=\"return confirm('一度削除したデータは元には戻せません。\\n削除してもよろしいですか？');\">削除</a>"
    helper.link_to_delete_address(@address).should == result_tag
  end

  it "会員お届け先の場合は削除リンクが生成されないこと" do
    address = DeliveryAddress.new.freeze
    result_tag = nil
    helper.link_to_delete_address(address).should == result_tag
  end
end
