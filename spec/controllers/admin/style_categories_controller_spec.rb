require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::StyleCategoriesController do
  fixtures :authorities, :functions, :admin_users
  fixtures :style_categories
  fixtures :styles

  before do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete this example and add some real ones
  it "should use Admin::StyleCategoryController" do
    controller.should be_an_instance_of(Admin::StyleCategoriesController)
  end

  describe "GET 'index'" do
    it "with id should be successful" do
      get 'index', :id => 10
      assigns[:style_category].should == StyleCategory.find_by_id(10)
      assigns[:style_categories].should_not be_nil
    end

    it "with style_id should be successful" do
      get 'index', :style_id => 1
      assigns[:style_category].style_id.should == 1
    end

    it "with id and style_id should get id's StyleCategory" do
      get 'index', :id => 40, :style_id => 1
      assigns[:style_category].style_id.should_not == 1
      assigns[:style_category].style_id.should == 4
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should redirect_to(:action => "index")
      assigns[:style_category].style_id.should be_nil
    end

    it "with style_id should new StyleCategory" do
      get 'new', :style_id => 1
      response.should redirect_to(:action => "index", :style_id => 1)
    end
  end

  describe "POST 'create'" do
    it "should be successful" do
      post "create", :style_category => {:style_id => 1, :name => "test"}
      StyleCategory.find(:last).name.should == "test"
    end

    it "other shop should not be successful" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      lambda { post "create", :style_category => {:style_id => 1, :name => "test2"} }.should raise_error(ActiveRecord::RecordNotFound)
      StyleCategory.find(:last).name.should_not == "test2"
    end

  end
  
  describe "POST 'update'" do
    it "should be successful" do
      post "update", :id => 60, :style_category => {:style_id => 6, :name => "test"}
      StyleCategory.find_by_id(60).name.should == "test"
    end

    it "other shop should not be successful" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      lambda { post "update", :id => 60, :style_category => {:style_id => 6, :name => "test2"} }.should raise_error(ActiveRecord::RecordNotFound)
      StyleCategory.find_by_id(60).name.should_not == "test2"
    end

  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy', :id => 60
      StyleCategory.find_by_id(60).should be_nil
    end

    it "other shop should not be successful" do
      session[:admin_user] = admin_users(:admin18_retailer_id_is_another_shop)
      lambda { get 'destroy', :id => 60 }.should raise_error(ActiveRecord::RecordNotFound)
      StyleCategory.find_by_id(60).should_not be_nil
    end

  end


  describe "GET 'up'" do
    it "should be successful" do
      get 'up', :id => 50
      StyleCategory.find_by_id(50).position.should == 4
      StyleCategory.find_by_id(20).position.should == 5
    end
  end

  describe "GET 'down'" do
    it "should be successful" do
      get 'down', :id => 20
      StyleCategory.find_by_id(20).position.should == 5
      StyleCategory.find_by_id(50).position.should == 4
    end
  end
end
