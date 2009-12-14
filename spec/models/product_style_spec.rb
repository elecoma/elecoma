require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProductStyle do
  fixtures :product_styles, :products
  before(:each) do
    @product_style = product_styles(:valid_product)
  end

  describe "validateチェック" do
    it "データが正しい" do
      @product_style.should be_valid
    end
    it "商品コード" do
      #非必須
      @product_style.code = nil ;
      @product_style.should be_valid
      #フォーマット
      @product_style.code = "aあ" ;
      @product_style.should_not be_valid
    end
    it "値段" do
      #必須
      @product_style.sell_price = nil
      @product_style.should_not be_valid
      @product_style.sell_price = 0
      @product_style.should_not be_valid
      #数字
      @product_style.sell_price = "aaa"
      @product_style.should_not be_valid
      #桁数(10桁以下)
      @product_style.sell_price = 9999999999
      @product_style.should be_valid
      @product_style.sell_price = 10000000000
      @product_style.should_not be_valid
    end
    it "規格" do
      #規格1が無い状態で規格 2を登録出来ません
      @product_style.style_category1 = nil
      @product_style.should_not be_valid
    end
    
  end
  describe "金額計算系" do
    it "税込販売額" do
      @product_style.including_tax_sell_price.should == @product_style.sell_price
      product_style = ProductStyle.new(:sell_price => 15000)
      product_style.including_tax_sell_price.should == 15000 
    end
  end
  describe "表示系" do
    fixtures :style_categories
    it "規格分類込みの名称" do
      #ケース１：商品名のみがある
      product_style = ProductStyle.new(:product_id => products(:valid_product).id,:sell_price => 15000)
      product_style.full_name.should == products(:valid_product).name
      #ケース２：（商品名　+　style_category_id1）がある場合、商品名　+　style_category_id1を戻る
      product_style = ProductStyle.new(:product_id => products(:valid_product).id,:style_category_id1 => style_categories(:can_incriment).id,:sell_price => 15000)
      product_style.full_name.should == products(:valid_product).name + ' ' + style_categories(:can_incriment).name
      
      #ケース３：（商品名　+　style_category_id2）がある場合、商品名を戻る
      product_style = ProductStyle.new(:product_id => products(:valid_product).id,:style_category_id2 => style_categories(:can_not_incriment).id,:sell_price => 15000)
      product_style.full_name.should == products(:valid_product).name
      
      #ケース４：（商品名　+　style_category_id1 + style_category_id2）が揃う場合、３つ結合で戻る
      @product_style.full_name ==  products(:valid_product).name + ' ' + style_categories(:have_classcateogry1).name + ' ' + style_categories(:can_incriment).name
    end
    it "商品名" do
      product_style = ProductStyle.new(:product_id=>products(:valid_product).id,:sell_price => 15000)
      product_style.product_name.should == products(:valid_product).name
      
      product_style = ProductStyle.new(:sell_price => 15000)
      product_style.product_name.should be_nil
    end
  end
  describe "その他" do
    it "データ初期化" do
      #実際在庫数
      product_style = ProductStyle.new(:sell_price => 15000)
      product_style.actual_count.should == 0
      product_style = ProductStyle.new(product_styles(:valid_product).attributes)
      product_style.actual_count.should == product_styles(:valid_product).actual_count
    end
    it "購入可能数を戻る" do
      #購入制限あり
      #購入上限 = 5,実際在庫 = 3,購入数 = Parameter
      product_style = ProductStyle.new(:product_id=>products(:limited_in_sep).id,:sell_price => 15000,:actual_count=>3)      

      #ケース１： 実際在庫 < 購入上限 < 購入数 の場合、実際在庫数を戻る
      product_style.available?(10).should == product_style.actual_count
      #ケース２：購入上限 < 実際在庫 < 購入数 の場合、購入制限数を戻る
      product_style.actual_count = 6
      product_style.available?(10).should == product_style.product.sell_limit
      #ケース３：購入数< 購入上限 < 実際在庫の場合、購入数を戻る
      product_style.available?(2).should == 2
      #ケース４：購入数< 実際在庫  < 購入上限 の場合、購入数を戻る
      product_style.actual_count = 3
      product_style.available?(2).should == 2
      product_style.available?(3).should == 3 
      #購入制限なし
      #テストデータの在庫数:1000
      #ケース１：購入数< 実際在庫数
      @product_style.available?(@product_style.actual_count-1).should == @product_style.actual_count-1
      #ケース2購入数 > 実際在庫数
      @product_style.available?(@product_style.actual_count+1).should == @product_style.actual_count
      @product_style.available?(@product_style.actual_count).should == @product_style.actual_count
    end
    it "受注により在庫数が変わる" do
      #在庫数1000
      cnt_b = @product_style.actual_count
      @product_style.order(2)
      @product_style.actual_count.should == cnt_b-2
      #在庫数0
      product_style = product_styles(:multi_styles_product_3)
      #例外が発生する箇所を、lambdaでくくる必要がある
      lambda{
        product_style.order(1)
      }.should raise_error(RuntimeError,"実在個数が0です")
    end
  end
end
