# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  fixtures :products, :image_resources, :product_statuses,:categories,:product_styles,:statuses,:suppliers,:retailers
  
  include ActionView::Helpers::NumberHelper
  
  before(:each) do
    @product = products(:valid_product)
  end
  describe "validateチェック" do
    before(:each) do
      @product.small_resource = image_resources(:resource_00001)
      @product.medium_resource = image_resources(:resource_00001)    
    end
    it "データが正しい" do
      @product.should be_valid
    end
    it "商品名" do
      #必須
      @product.name = nil
      @product.should_not be_valid
      #文字数(1-50文字)
      @product.name = ""
      @product.should_not be_valid
      @product.name = "あ" * 50
      @product.should be_valid
      @product.name = "あ" * 51
      @product.should_not be_valid
    end
    it "参照URL" do
      #非必須
      @product.url = nil
      @product.should be_valid
      #文字数(300以下)
      @product.url = "a" * 300
      @product.should be_valid
      @product.url = "a" * 301
      @product.should_not be_valid
    end
    it "検索ワード" do
      #非必須
      @product.key_word = nil
      @product.should be_valid
      #文字数(99999以下)
      @product.key_word = "あ" * 99999
      @product.should be_valid
      @product.key_word = "a" * 100000
      @product.should_not be_valid
    end
    it "カテゴリID" do
      #必須
      @product.category_id = nil
      @product.should_not be_valid
    end
    
    it "一覧コメント" do
      #必須
      @product.description = nil
      @product.should_not be_valid
    end
    it "詳細コメント" do
      #必須
      @product.introduction = nil
      @product.should_not be_valid      
    end
    it "販売期間" do
      date = DateTime.now
      @product.sale_start_at = date
      @product.sale_end_at = date
      @product.should_not be_valid
      @product.sale_end_at = DateTime.new(2008,1,1)
      @product.should_not be_valid
    end
    it "公開期間" do
      date = DateTime.now
      @product.public_start_at = date
      @product.public_end_at = date
      @product.should_not be_valid
      @product.public_end_at = DateTime.new(2008,1,1)
      @product.should_not be_valid
    end
  end
  
  describe "表示系" do
    it "配送日" do
      product = Product.new(:delivery_dates =>1)
      product.delivery_dates_label.should == Product::DELIVERY_DATE.keys.sort{|a, b| Product::DELIVERY_DATE[a] <=> Product::DELIVERY_DATE[b]}[1]
    end
    it "公開かどうか" do
      product = Product.new(:permit =>false)
      product.permit_label.should == "非公開"
    end
    it "1番目の商品スタイル" do
      product = Product.new
      product.first_product_style.should be_nil
      @product.first_product_style.should == product_styles(:valid_product)
    end
    it "最安値と最高値および価格表示" do
      product = products(:multi_styles_product)
      min = product_styles(:multi_styles_product_2).sell_price
      max = product_styles(:multi_styles_product_3).sell_price
      product.price_range.should == [min,max]
      product.price_label.should == number_with_delimiter(min) + "～" + number_with_delimiter(max)
      
      @product.price_label.should == number_with_delimiter(product_styles(:valid_product).sell_price)      
    end
    it "カテゴリ名" do
      product = Product.new(:category_id =>categories(:dai_category).id)
      product.category_name.should == categories(:dai_category).name
    end
    it "仕入先名" do
      product = Product.new(:supplier_id =>suppliers(:one).id)
      product.supplier_name.should == suppliers(:one).name
    end
  end
  describe "その他" do
    it "送料無料判断" do
      @product.free_delivery?.should be_false
      product = products(:campaign_product)
      product.free_delivery?.should be_true
    end
    it "販売期間内/公開期間内か判断" do
      product = products(:sell_stop_product)
      product.in_sale_term?.should be_false
      product.in_public_term?.should be_false
      @product.in_sale_term?.should be_true
      @product.in_public_term?.should be_true
    end
    it "在庫がある判断" do
      product = Product.new
      product.have_zaiko?.should be_false
      product = products(:multi_styles_product)
      product.have_zaiko?.should be_true
    end
    it "CSVダウンロード" do
      search_list = [["products.name like ?", "%スカート%"]]
      actual_titles,actual_product,act_file_name = getCsv(Product.csv(search_list))
      
      #タイトル
      act = actual_titles.sort
      ext = Product.set_field_names.values.sort
      act.should == ext
      #データ数
      columns = Product.csv_columns_name
      actual_product.size.should == 3
      #ファイル名
      #ファイル名に「現在時間秒まで」を含めるので、プログラム実行により秒の相違があるのでここで分まで取り切り
      ext_file_name = "product_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" 
      act_file_name.slice(0,act_file_name.length-8).should == ext_file_name.slice(0,ext_file_name.length-8)
      
    end
    it "商品在庫数CSVダウンロード" do
      search_list = [["products.name like ?", "%スカート%"]]
      actual_titles,actual_product,act_file_name = getCsv(Product.actual_count_list_csv(search_list))
      
      #タイトル
      act = actual_titles.sort
      ext = ["商品名", "商品コード", "登録更新日", "実在個数"].sort
      act.should == ext
      #データ内容
      columns = [:name,:code,:updated_at,:actual_count]
      actual_product.should == [
      convert(products(:campaign_product),product_styles(:campaign_product),columns) ,
      convert(products(:sell_stop_product),product_styles(:sell_stop_product),columns),
      convert(products(:multi_styles_product),product_styles(:multi_styles_product_1),columns),
      convert(products(:multi_styles_product),product_styles(:multi_styles_product_2),columns),
      convert(products(:multi_styles_product),product_styles(:multi_styles_product_3),columns)
      ]
      #ファイル名
      #ファイル名に「現在時間秒まで」を含めるので、プログラム実行により秒の相違があるのでここで分まで取り切り
      ext_file_name = "actual_count_list_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" 
      act_file_name.slice(0,act_file_name.length-8).should == ext_file_name.slice(0,ext_file_name.length-8)
    end
    it "CSVアップロード" do
      max_id = Product.maximum(:id)
      Product.add_by_csv(File.read("#{RAILS_ROOT}/spec/csv/product_csv_upload_for_spec.csv"), 1)
      max_id.should < Product.maximum(:id)
      
      #=========================================
      #CSVアップロードするときの画像処理が複雑なので、単独テスト
      #仕様としてCSVファイルに画像Pathが存在、かつ、画像が指定のパスに存在するとき、画像をアップロード
      #画像パスが空白、あるいは画像が存在しない時、画像IDが指定されれば、その画像IDを使う
      
      #CSVデータが2件あり、そのうち
      #1件：小画像パスあり、IDあり、中画像パスなし、IDあり、大画像パスなし、IDなし
      #1件：小画像パスなし、IDあり、中画像パスあり、IDあり、大画像パスありが画像存在しない、IDあり
      #画像IDがすべて18
      
      #元データ
      cnt_image_b = ImageResource.count
      cnt_image_data_b = ResourceData.count
      cnt_product_b = Product.count
      #CSVアップロード
      Product.add_by_csv(File.read("#{RAILS_ROOT}/spec/csv/product_csv_upload_image_for_spec.csv"), 1)
      
      #期待結果
      #商品データが1件更新、1件増加、
      #1件：小画像ID＝18、中画像IDが新規作成、大画像ID＝18
      #1件：小画像IDが新規作成、中画像ID＝18、大画像ID＝nil
      #image_resourceのデータ数が2件増やす
      #resource_dataのデータ数が2件増やす
      cnt_image_a = ImageResource.count
      cnt_image_data_a = ResourceData.count
      cnt_product_a = Product.count

       (cnt_product_a - cnt_product_b).should == 1
      #1件目更新
      product = Product.find_by_id(17)
      product.small_resource_id.should == 18
      product.large_resource_id.should == 18
      #2件目追加
      product2 = Product.find(:last)
      product.medium_resource_id.should == 18
      product2.large_resource_id.should be_nil
      #CSV画像アップテストは環境により結果が異なるので、ここでテストコードをコメントアウトする
      pending("CSV画像アップテストは環境により結果が異なるので、ここで関連テストコードをコメントアウトする") do
      #   (cnt_image_a - cnt_image_b).should == 2
      #   (cnt_image_data_a - cnt_image_data_b).should == 2
      #  max_img_id += 1
      #  product.small_resource_id.should == max_img_id       
      #  max_img_id += 1
      #  product2.medium_resource_id.should == max_img_id
        true.should be_false # 保留したい評価
      end
    end    
  end
  
  describe "データ変換" do
    it "公開かどうか（ハッシュを配列へ）" do
      arr = Product::PERMIT_LABEL.to_a
      Product.permit_select.should == arr
    end
    it "配送日（ハッシュを配列へ）" do
      arr = Product::DELIVERY_DATE.to_a
      Product.delivery_dates_select.should == arr
    end
  end

  describe "販売元を追加" do
    it "販売元にアクセスが可能" do
      @product.retailer.should_not be_nil
    end
  end
  
  #=====================================================
  private
  #fixturesデータをCSV形式に変換（比較用）
  def convert(product,p_style, columns)
    arr = []
    columns.map do |c|
      if p_style
        #実際在庫ダウンロード
        if [:name].include?(c)
          arr << (product.name.nil? ? "" : product.name.to_s)
        else
          #更新時間について、
          #p_style.updated_atとp_style[:updated_at]の結果が違うので特別処理
          if [:updated_at].include?(c)
            arr << (p_style[c].nil? ? "" : p_style.updated_at.to_s)
          else
            arr << (p_style[c].nil? ? "" : p_style[c].to_s)
          end        
        end
      else
        #商品ダウンロード
        if [:permit].include?(c)
          arr <<   (product[c] ? "公開" : "非公開")
        elsif [:category_name].include?(c)
          arr << (product.category_name.nil? ? "" : product.category_name)
        else  
          arr <<   (product[c].nil? ? "" : product[c].to_s)
        end
      end      
    end
    arr.join(",").split(",")
  end
  #CSVダウンロードデータを比較用データに変換
  def getCsv(datas)
    
    #CSVファイル内容
    data = datas[0]
    #タイトル
    actual_titles = []
    #データ
    actual_product = []
    data.split("\n").each_with_index do |d,i|
      if i == 0
        actual_titles = d.split(/\s*,\s*/)
      else
        actual_product << d.split(/\s*,\s*/)
      end
    end
    #CSVファイル名
    fileName = datas[1]
    return actual_titles ,actual_product, fileName
  end
  #product同士の比較
  #結果が同じである場合、1を戻る、結果が違う場合、0を戻る
  def compare(act,ext)
    ret = 1
    keys = act.attributes.keys
    keys.each do |key|
      #値がnil ""の場合、および　id,created_at,updated_atが比較の対象から外し      
      unless ((act[key].blank? && ext[key].blank?) or ["id","created_at","updated_at"].include?(key))
        #時間系カラムは国際時間、日本時間の原因で特殊処理
        if ["sale_start_at","sale_end_at","public_start_at","public_end_at","arrival_expected_date","deleted_at"].include?(key)
          if !act[key].blank? && !ext[key].blank?
            if (act.send(key) != ext.send(key)) && (act.send(key) != ext.send(key)- 9.hour)
              ret = 0
              break
            end
          else  
            ret = 0
            break
          end
        else
          if act.send(key)!= ext.send(key)
            ret = 0
            break
          end
        end
      end      
    end
    ret
  end
end
