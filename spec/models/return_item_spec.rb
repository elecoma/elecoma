# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReturnItem do
  fixtures :return_items

  describe "validateチェック" do
    before do
      @ri = return_items(:return_items_2)
    end

    it "should ok" do
      @ri.comment = "a" * 10000
      @ri.should be_valid
    end
  
    it "commentは10000文字以内" do
      @ri.comment = "a" * 10001
      @ri.should_not be_valid
    end
  end

end

