require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::StylesController do
  fixtures :products, :authorities, :functions, :admin_users, :categories, :resource_datas, :image_resources
  fixtures :styles

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete this example and add some real ones
  it "should use Admin::StylesController" do
    controller.should be_an_instance_of(Admin::StylesController)
  end

  describe "GET index" do
    it "should be successful" do
      get 'index'
      assigns[:styles].should_not be_nil
      assigns[:style].should_not be_nil
    end

    it "with id should be get style" do
      get 'index', :id => 1
      assigns[:styles].should_not be_nil
      assigns[:style].should == Style.find_by_id(1)
    end

  end

  describe "GET 'new'" do
    it "should be redirect_to 'index'" do
      get 'new'
      response.should redirect_to(:action => "index")
    end
  end

  describe "create" do
    it "should be successful" do
      post 'create', :style => {:name => "test"}
      response.should redirect_to(:action => "index")
      Style.find(:last).name.should == "test"
    end
  end
  
  describe "update" do
    it "should be successful" do
      get 'index', :id => 1
      post "update", :id => 1, :style => {:name => "test"}
      response.should redirect_to(:action => "index")
      Style.find_by_id(1).name.should == "test"
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy', :id => 1
      response.should redirect_to(:action => "index")
      Style.find_by_id(1).should be_nil
    end
  end

  describe "GET 'up'" do
    it "should be successful" do
      get 'up', :id => 1
      Style.find_by_id(1).position.should == 1
      Style.find_by_id(3).position.should == 2
    end
  end
  
  describe "GET 'up'" do
    it "should be successful" do
      get 'down', :id => 1
      Style.find_by_id(1).position.should == 3
      Style.find_by_id(4).position.should == 2
    end
  end



end
