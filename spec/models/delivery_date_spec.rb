# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryDate do
  before(:each) do
    @delivery_date = DeliveryDate.new
  end
  describe "validateチェック" do
    it "データがただしい" do
      @delivery_date.should be_valid
    end
  end
end
