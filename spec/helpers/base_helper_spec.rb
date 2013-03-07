# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe BaseHelper do
  fixtures :delivery_addresses
  
  #Delete this example and add some real ones or delete this file
  it "should include the BaseHelper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(BaseHelper)
  end
  
  it "追加お届け先が20件未満の場合" do
    @address_size = assigns[:address_size] = 19
    helper.link_to_create_address.should_not be_nil
  end

  it "追加お届け先が20件以上の場合" do
    @address_size = assigns[:address_size] = 20
    result_tag = nil
    helper.link_to_create_address.should == result_tag
  end
end
