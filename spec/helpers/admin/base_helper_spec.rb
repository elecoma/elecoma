require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::BaseHelper do

  #Delete this example and add some real ones or delete this file
  it "should include the Admin::BaseHelper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(Admin::BaseHelper)
  end
  
  describe "calendar_date_select" do  
    
    subject {@object = Order.new() }

    it "should return 'script' " do
      helper.calendar_date_select(@object,:mthd,{},{}).index("script").should_not == nil
    end

    it "should return 'img'" do
      helper.calendar_date_select(@object,:mthd,{},{}).index("img").should_not == nil
    end

    it "should return 'SelectCalendar.createOnLoaded'" do
      helper.calendar_date_select(@object,:mthd,{},{}).index("SelectCalendar.createOnLoaded").should_not == nil
    end

  end
end
