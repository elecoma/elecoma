# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  fixtures :prefectures
  it "日付を年月日表示" do
    date = Date.today
    helper.date_jp(date).should == date.strftime("%Y年%m月%d日")
  end

  it "日付を年月日表示" do
    date = Date.today
    helper.date_month_day_jp(date).should == date.strftime("%m月%d日")
  end
  
  it "都道府県名表示" do
    1.step(47){|i|
    helper.prefecture_name(i).should== Prefecture.find(i).name
    
    }
  end
end
