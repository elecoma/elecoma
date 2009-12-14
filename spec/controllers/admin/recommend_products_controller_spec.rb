require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::RecommendProductsController do
  fixtures :admin_users , :recommend_products, :products, :product_styles
  before(:each) do
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end

  #Delete these examples and add some real ones
  it "should use Admin::RecommendProductController" do
    controller.should be_an_instance_of(Admin::RecommendProductsController)
  end


  describe "GET 'index'" do
    it "初期表示の場合" do
      get 'index'
      response.should be_success
      assigns[:recommend_products].should == RecommendProduct.find(:all, :order => "position")
    end
  end

  describe "POST 'update'" do
    it "データを更新する場合" do
      recommend_product = {:description => "オススメ商品です"}
      get 'update', :id=>1, :product_id=>1, :recommend_product => recommend_product
      RecommendProduct.find_by_id(1).description.should == recommend_product[:description]
      response.should redirect_to(:action=>"index")
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      #初期データの確認
      RecommendProduct.find(2).description.should == recommend_products(:test3).description
      RecommendProduct.find(2).product_id.should == recommend_products(:test3).product_id

      get 'destroy', :id=>2
      RecommendProduct.find_by_id(2).should be_nil
      flash[:notice].should == "削除しました"
      response.should redirect_to(:action=>"index")
    end

  end

  describe "GET 'update'" do
    it "データの更新に成功した場合" do
      recommend_product = {:product_id=>3, :description=>"データを更新しました"}
      get 'update', :id=>1, :recommend_product => recommend_product
      record = RecommendProduct.find(1)
      record.product_id.should == 3
      flash[:notice] = "保存しました"
      response.should redirect_to(:action=>"index")
    end

    it "データの更新に成功した場合（登録されていなかったところに登録）" do
      recommend_product = {:product_id=>3, :description=>"データを更新しました"}
      get 'update', :id=>3, :recommend_product => recommend_product
      record = RecommendProduct.find(3)
      record.product_id.should == 3
      record.description.should == "データを更新しました"
      flash[:notice] = "保存しました"
      response.should redirect_to(:action=>"index")
    end

    it "データの更新に失敗した場合" do
      recommend_product = {:product_id=>3, :description=> "a" * 1000}
      get 'update', :id=>6, :recommend_product => recommend_product
      RecommendProduct.find_by_id(6).description.should_not == "a" * 1000
      response.should render_template("admin/recommend_products/edit.html.erb")
    end
  end

  describe "GET 'product_search'" do
    it "検索画面が表示される" do
      get 'product_search', :id => "1"
      assigns[:products].should be_nil
      response.should be_success
    end
    
    it "商品が検索できる（商品名のみで検索）" do
      condition = {:keyword => "can", :searched => "true"}
      get 'product_search', :id => '1', :condition => condition
      assigns[:products].should_not be_nil
      response.should render_template("admin/recommend_products/product_search.html.erb")
    end

    it "商品が検索できる（カテゴリーのみで検索）" do
      condition = {:category_id => '1', :searched => "true"}
      get 'product_search', :id => '1', :condition => condition
      assigns[:products].should_not be_nil
      response.should render_template("admin/recommend_products/product_search.html.erb")
    end

    it "商品が検索できる（商品名とカテゴリーで検索）" do
      condition = {:keyword => "商品", :category_id => '1', :searched => "true"}
      get 'product_search', :id=>'1', :condition => condition
      assigns[:products].should_not be_nil
      response.should render_template("admin/recommend_products/product_search.html.erb")
    end

    it "商品が検索できる（条件なしで検索）" do
      condition = {:searched => "true"}
      get 'product_search', :id=>'1', :condition => condition
      assigns[:products].should_not be_nil
      response.should render_template("admin/recommend_products/product_search.html.erb")
    end

    it "商品が検索できる（1件もひっかからない）" do
      condition = {:keyword => "test", :category_id => '1', :searched => "true"}
      get 'product_search', :id=>'1', :condition => condition
      assigns[:products].should == []
      response.should render_template("admin/recommend_products/product_search.html.erb")
    end
  end

end
