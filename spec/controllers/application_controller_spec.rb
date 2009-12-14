require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  fixtures :zips, :systems

  it "should use ApplicationController" do
    controller.should be_an_instance_of(ApplicationController)
  end

  describe "load_system" do
    it "should be" do
      get 'load_system'
      assigns[:system].should_not be_nil
    end
  end

  describe "GET 'get_address'" do
    it "アドレス情報が取得できる" do
      get 'get_address', :first => "000", :second => "0000"
      address = zips(:zip_test_id_1)
      data = address.prefecture_name + "/" + address.address_city + "/" + address.address_details + "/" + address.prefecture_id.to_s
      response.should be_success
      response.body.should == data
    end
  end

end
