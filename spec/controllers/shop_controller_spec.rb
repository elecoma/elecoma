require File.dirname(__FILE__) + '/../spec_helper'

describe ShopController do
  fixtures :shops

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use ShopController" do
    controller.should be_an_instance_of(ShopController)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
      assigns[:shop].should_not be_nil
      assigns[:shop].attributes.should == Shop.find(:first).attributes
    end
  end
end
