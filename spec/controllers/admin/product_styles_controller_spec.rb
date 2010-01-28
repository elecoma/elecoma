require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ProductStylesController do
  fixtures :authorities, :functions, :admin_users
  fixtures :product_styles, :products, :styles
  
  before do
    session[:admin_user] = admin_users(:admin10)
    @valid_product = products(:valid_product)
    @controller.class.skip_before_filter @controller.class.before_filter
    @controller.class.skip_after_filter @controller.class.after_filter
  end


  #Delete this example and add some real ones
  it "should use Admin::ProductStylesController" do
    controller.should be_an_instance_of(Admin::ProductStylesController)
  end

  describe "GET 'new'" do
    it 'with id should be successful' do
      get 'new', :id => @valid_product.id
      assigns[:product].should_not be_nil
    end

    it 'without id should raise exception' do
      lambda { get 'new' }.should raise_error(NoMethodError)
    end
  end

  describe "POST 'create_form'" do
    before do
      @product_style_test = products(:product_style_test)
    end
    it '規格2のみではエラーとなる' do
      post 'create_form', :id => @product_style_test.id, :style_id1 => "", :style_id2 => 5
      assigns[:error_message].should_not be_nil
    end

    it '規格1と規格2が同一だとエラーになる' do
      post 'create_form', :id => @product_style_test.id, :style_id1 => 5, :style_id2 => 5
      assigns[:error_message].should_not be_nil
    end

    it '正常のパターン' do
      post 'create_form', :id => @product_style_test.id, :style_id1 => 5, :style_id2 => 6
      assigns[:error_message].should be_nil
    end

  end

  describe "POST 'confirm'" do
    before do
      @product_style_test = products(:product_style_test)
    end

    it '確認画面に正常に遷移' do
      product_styles = Hash.new
      one_product_style = {:enable => "on", :style_category1 => 50, :style_category2 => 60, :code => "VVM0001", :sell_price => 1200}
      product_styles[product_styles.count.to_s] = one_product_style
      post 'confirm', :id => @product_style_test.id, :product_id => @product_style_test.id, :product_styles => product_styles
      assigns[:save_flg].should be_true
    end
  end

  describe "POST 'create'" do
    before do
      @product_style_test = products(:product_style_test)
    end

    it '登録可能な状態' do
      product_styles = Hash.new
      one_product_style = {:enable => "on", :style_category1 => 50, :style_category2 => 60, :code => "VVM0001", :sell_price => 1200}
      product_styles[product_styles.count.to_s] = one_product_style
      post 'create', :id => @product_style_test.id, :product_id => @product_style_test.id, :product_styles => product_styles
      assigns[:save_flg].should be_true
    end

    it '登録失敗' do
      product_styles = Hash.new
      one_product_style = {:enable => "on", :style_category1 => 50, :style_category2 => 60, :code => "VVM0001", :sell_price => "334io"}
      product_styles[product_styles.count.to_s] = one_product_style
      post 'create', :id => @product_style_test.id, :product_id => @product_style_test.id, :product_styles => product_styles
      assigns[:save_flg].should_not be_true
    end
  end
end
