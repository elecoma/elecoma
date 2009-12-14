require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FeatureProductsController do
  fixtures :admin_users,:features,:feature_products,:resource_datas, :image_resources,:products,:product_styles,:styles,:categories
  before do 
    session[:admin_user] = admin_users(:admin10)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
    @f = features(:permit)
    @f_product = feature_products(:feature1)
  end
  #Delete this example and add some real ones
  it "should use Admin::FeatureProductsController" do
    controller.should be_an_instance_of(Admin::FeatureProductsController)
  end
  
  describe "GET 'index'" do
    it "成功する" do
      get 'index',:feature_id =>@f.id
      assigns[:feature].should_not be_nil
      assigns[:feature_products].should_not be_nil
    end
    it "失敗する" do
      #指定の特集IDが存在しない場合
      lambda { get 'index',:feature_id =>1000 }.should raise_error
    end    
  end
  describe "GET 'new'" do
    it "成功" do
      post 'new',:feature_id =>@f.id
      assigns[:feature_product].should_not be_nil
      assigns[:feature_product].id.should be_nil
      assigns[:feature_product].feature_id.should == @f.id
    end
  end
  describe "POST 'confirm'" do
    before(:each) do
      require 'fileutils'
      @pic = ActionController::UploadedTempfile.new ""
      FileUtils.cp File.dirname(__FILE__) + "/../../../public/images/item/lt.gif", @pic.path
      @pic.reopen(@pic.path)
      @p = products(:campaign_product)
    end

    it "confirm単体(画像指定がある場合)" do
      resource_max = ImageResource.maximum(:id)
      post 'confirm', :feature_product => {:product_id => @p.id,:feature_id=>@f.id,:body=>"商品特集テストコードです",:image_resource=>@pic}
      assigns[:feature_product].product_id.should == @p.id
      assigns[:feature_product].feature_id.should == @f.id
      assigns[:feature_product].body.should == "商品特集テストコードです"      
      assigns[:feature_product].image_resource_id.should_not be_nil
      assigns[:feature_product].image_resource_id.should > resource_max
      response.should render_template("admin/feature_products/confirm.html.erb")
      #validateエラーがある場合
      post 'confirm', :feature_product => {:product_id => nil}
      response.should render_template("admin/feature_products/new.html.erb")
    end
    it "confirm単体(画像指定がない場合)" do
      post 'confirm', :feature_product => {:product_id => @p.id,:feature_id=>@f.id,:body=>"商品特集テストコードです"}
      assigns[:feature_product].product_id.should == @p.id
      assigns[:feature_product].feature_id.should == @f.id
      assigns[:feature_product].body.should == "商品特集テストコードです"      
      #画像が指定されていない場合、商品の小画像をデフォルトで設定される
      assigns[:feature_product][:image_resource].attributes.should == @p.small_resource.attributes
      response.should render_template("admin/feature_products/confirm.html.erb")
    end      
  end
  describe "GET 'edit'" do
    it "成功するパターン" do
      get 'edit', :id => @f_product.id
      assigns[:feature_product].should_not be_nil
      assigns[:feature_product].attributes.should == @f_product.attributes
    end

    it "失敗するパターン" do
      lambda { get 'edit', :id => 10000 }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "POST 'create'" do   
    it "正常に追加できるパターン" do
      max_id = FeatureProduct.maximum(:id)
      post 'create', :feature_product => {:product_id => 18,:feature_id=>@f.id,:body=>"商品特集テストコードです",:image_resource_id=>18}
      assigns[:feature_product].should_not be_nil
      assigns[:feature_product].id.should > max_id
      response.should redirect_to(:action => :index,:feature_id=>@f.id)
    end

    it "feature_productが不正なパターン" do
      new_id = FeatureProduct.maximum(:id) + 1
      post 'create', :feature_product => {:product_id => nil}
      assigns[:feature_product].should_not be_nil
      assigns[:feature_product].id.should be_nil
      response.should_not be_redirect
      response.should render_template("admin/feature_products/new.html.erb")
    end
  end
  describe "POST 'update'" do
    it "正常に更新できるパターン" do
      #更新前
      FeatureProduct.find_by_id(@f_product.id).body.should be_nil
      post 'update', :id => @f_product.id, :feature_product => @f_product.attributes.merge(:body=>"商品特集編集テストです")
      #更新後
      check = FeatureProduct.find_by_id(@f_product.id)
      response.should redirect_to(:action => :index,:feature_id=>@f.id)
    end

    it "feature_productが不正なパターン" do      
      post 'update', :id => @f_product.id, :feature_product => {:product_id => nil}
      check = FeatureProduct.find_by_id(@f_product.id)
      check.attributes.should == @f_product.attributes
      response.should_not be_redirect
      response.should render_template("admin/feature_products/edit.html.erb")
    end      
  end
  describe "POST 'product_search'" do
    
    it "商品検索1-searchedが渡されていない" do
      post 'product_search',:condition =>{:keyword =>'スカート'}
      assigns[:products].should be_nil
    end
    it "商品検索2-keywordが渡されてる" do
      post 'product_search',:condition =>{:keyword =>'スカート',:searched=>'true'}
      #期待結果:5件ヒット
      assigns[:products].should_not be_nil
      assigns[:products].length.should == 5
      assigns[:products][0].attributes.should == product_styles(:campaign_product).attributes
      assigns[:products][1].attributes.should == product_styles(:sell_stop_product).attributes
      act = [assigns[:products][2].attributes,assigns[:products][3].attributes,assigns[:products][4].attributes].sort{|a, b| a["id"] <=> b["id"]}
      ext = [product_styles(:multi_styles_product_1).attributes,product_styles(:multi_styles_product_2).attributes,product_styles(:multi_styles_product_3).attributes].sort{|a, b| a["id"] <=> b["id"]}
      act.should == ext
    end
    it "商品検索3-category_idが渡されてる" do
      post 'product_search',:condition =>{:category_id =>'16',:searched=>'true'}
      #期待結果:1件ヒット
      assigns[:products].should_not be_nil
      assigns[:products].length.should == 1
      assigns[:products][0].attributes.should == product_styles(:valid_product).attributes
    end
    it "商品検索4-keywordとcategory_idが渡されてる" do
      post 'product_search',:condition =>{:category_id =>'1',:keyword =>'シャツ',:searched=>'true'}
      #期待結果:1件ヒット
      assigns[:products].should_not be_nil
      assigns[:products].length.should == 1
      assigns[:products][0].attributes.should == product_styles(:not_permit_product).attributes
    end    
   end
end
