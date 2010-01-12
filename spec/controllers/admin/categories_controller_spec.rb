require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::CategoriesController do
  fixtures :admin_users
  fixtures :categories

  before do
    session[:admin_user] = admin_users(:admin10)
  end

  #Delete this example and add some real ones
  it "should use Admin::CategoriesController" do
    controller.should be_an_instance_of(Admin::CategoriesController)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      assigns[:category].id.should be_nil
      assigns[:categories].should_not be_nil
    end

    it "大カテゴリ" do
      get 'index', :id => 1
      assigns[:category].should_not be_nil
      assigns[:categories].should_not be_nil
    end

    it "中カテゴリ" do
      get 'index', :id => 2
      assigns[:category].should_not be_nil
      assigns[:categories].should_not be_nil
    end
  end
   
  describe "POST 'create'" do
    it "親カテゴリを作成" do
      category = {:name => "Test", :free_space => "free space"}
      post 'create', :category => category
      response.should redirect_to(:action => "index")
      Category.find(:last).parent_id.should be_nil
    end

    it "中カテゴリを作成" do
      category = {:name => "Test", :free_space => "free space", :parent_id => 1}
      post 'create', :category => category
      response.should redirect_to(:action => "index", :category_id => 1)
      Category.find(:last).parent_id.should_not be_nil
    end
    
  end

  describe "POST 'update'" do
    it "親カテゴリを編集" do
      category = {:id => 1, :name => "Parent Category", :free_space => "free space"}
      post 'update', :id => 1, :category => category
      response.should redirect_to(:action => "index")
      Category.find_by_id(1).parent_id.should be_nil
    end

    it "中カテゴリを編集" do
      category = {:id => 2, :name => "Mid Category", :free_space => "free space"}
      post 'update', :id => 2, :category => category
      response.should redirect_to(:action => "index", :category_id => 1)
      Category.find_by_id(2).parent_id.should_not be_nil
    end
  end

  describe "GET 'up'" do
    it "id 1(大カテゴリでトップ)をup" do
      get 'up', :id => 1
      Category.find_by_id(1).position.should == 1      
    end

    it "id 2(中カテゴリでトップ)をup" do
      get 'up', :id => 2
      Category.find_by_id(2).position.should == 1       
    end

    it "id 4(中カテゴリで2番目)をup" do
      get 'up', :id => 4
      Category.find_by_id(4).position.should == 1
      Category.find_by_id(2).position.should == 2
    end
  end

  describe "GET 'down'" do
    it "id 1(大カテゴリでトップ)をdown" do
      #lambda{get 'down', :id => 1}.should raise_error(NoMethodError)
      get 'down', :id => 1
      Category.find_by_id(1).position.should == 2      
    end

    it "id 2(中カテゴリでトップ)をdown" do
      get 'down', :id => 2
      Category.find_by_id(2).position.should == 2
      Category.find_by_id(4).position.should == 1
    end

    it "id 4(中カテゴリで二番目)をdown" do
      get 'down', :id => 4
      Category.find_by_id(4).position.should == 3
    end

  end

  describe "POST 'destroy'" do
    it "id 1を削除(ツリーを全て削除)" do
      Category.find_by_id(1).should_not be_nil
      get 'destroy', :id => 1
      Category.find_by_id(1).should be_nil
      Category.count.should == 1
    end

    it "id 2を削除(通常の削除)" do
      get 'destroy', :id => 2
      Category.find_by_id(2).should be_nil
      Category.find_by_id(4).position.should == 1
    end
    
  end

end

