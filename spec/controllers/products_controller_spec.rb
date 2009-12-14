require File.dirname(__FILE__) + '/../spec_helper'

describe ProductsController do
  fixtures :products, :categories, :seos, :product_styles, :styles, :style_categories

  before do
    @controller.class.skip_before_filter :start_transaction
    @controller.class.skip_after_filter :end_transaction
  end

  #Delete these examples and add some real ones
  it "should use ProductsController" do
    controller.should be_an_instance_of(ProductsController)
  end


  describe "GET 'show'" do
    it "商品をロード" do
      get 'show', :id => products(:test1).id
      assigns[:product].should_not be_nil
      response.should_not be_redirect
    end

    it "非公開商品はロードしない" do
      get 'show', :id => products(:permit_false).id
      assigns[:product].should be_nil
      response.should_not be_redirect
    end
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "商品をロードする" do
      get 'index'
      assigns[:products].should_not be_nil 
    end
    
    it "価格順にロードする" do
      get 'index', :order => "price"
      assigns[:products].should_not be_nil
    end

    it "カテゴリ商品をロードする" do
      load_category(categories(:dai_category).id)
      load_category(categories(:chu_category_two).id)
    end

    def load_category(id)
      get 'index', :category_id =>id 
      assigns[:category].should == Category.find(id)
    end
  end

  describe "POST 'show_image'" do
    it "商品をロード" do
      get 'show_image', :id => products(:test1).id
      assigns[:product].should_not be_nil
    end

    it "非公開商品はロードしない" do
      get 'show_image', :id => products(:permit_false).id
      assigns[:product].should be_nil
    end
  end

  describe "POST 'stock_table'" do
    it "should be successful" do
      post 'stock_table', :id => products(:test1).id  
      assigns[:product_styles].should_not be_nil
      response.should render_template("products/stock_table.html.erb")
    end

    it "スタイルなし" do
      post 'stock_table', :id => products(:product_style_test).id
      assigns[:product_styles].should_not be_nil
      assigns[:have_style].should be_false
      response.should render_template("products/stock_table.html.erb")
    end

    it "スタイルあり" do
      post 'stock_table', :id => products(:multi_styles_product).id
      assigns[:product_styles].should_not be_nil
      assigns[:have_style].should be_true
      assigns[:have_style2].should be_true
      assigns[:style_name1].should_not be_blank
      assigns[:style_name2].should_not be_blank
      response.should render_template("products/stock_table.html.erb")
      response.layout.should_not be_nil
    end
    it "partial" do
      post 'stock_table', :id => products(:multi_styles_product).id, :partial => true
      assigns[:product_styles].should_not be_nil
      assigns[:have_style].should be_true
      assigns[:have_style2].should be_true
      assigns[:style_name1].should_not be_blank
      assigns[:style_name2].should_not be_blank
      response.layout.should be_nil
    end

  end

end
