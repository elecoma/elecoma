# -*- coding: utf-8 -*-
class Product < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  acts_as_paranoid

  has_many :sub_products, :dependent => :delete_all , :order => "no"
  has_many :product_statuses, :order => :position
  has_many :statuses, :through => :product_statuses
  belongs_to :category
  belongs_to :small_resource,
             :class_name => "ImageResource",
             :foreign_key => "small_resource_id"
  belongs_to :medium_resource,
             :class_name => "ImageResource",
             :foreign_key => "medium_resource_id"
  belongs_to :large_resource,
             :class_name => "ImageResource",
             :foreign_key => "large_resource_id"
  has_many :recommend_products
  has_one :delivery_date
  has_many :styles
  has_many :product_styles, :dependent => :destroy, :order => 'position'
  has_many :order_details
  has_one :campaign
  belongs_to :supplier
  belongs_to :retailer

  validates_length_of :name , :maximum => 50
  validates_length_of :name , :minimum => 1
  validates_length_of :url , :maximum => 300, :allow_blank => true
  validates_length_of :key_word , :maximum => 99999, :allow_blank => true
  validates_presence_of :category_id
  validates_presence_of :small_resource
  validates_presence_of :medium_resource
  validates_presence_of :description
  validates_presence_of :introduction
  validates_presence_of :supplier
  validates_presence_of :retailer
  validates_associated :sub_products

  attr_accessor :small_resource_path
  attr_accessor :medium_resource_path
  attr_accessor :large_resource_path

  DEFAULT_INCLUDE =  [:product_statuses, :category]
  PERMIT_LABEL = {"公開" => true, "非公開" => false }

  DELIVERY_DATE = {  "1週間前後" => 0, "2週間前後" => 1, "3日後" => 3,
    "1週間以降" => 7, "2週間以降" => 14, "3週間以降" => 21, "1ヶ月以降" => 31,
    "2ヶ月以降" => 62, "お取り寄せ(商品入荷後)" => 99 }
  
  ZAIKO_MUCH,ZAIKO_LITTLE = 10,0
  
  def validate
    if sale_start_at and sale_end_at
      unless sale_start_at < sale_end_at
        errors.add :sale_end_at, "は販売開始日以降の日付を設定してください。"
      end
    end
    if public_start_at and public_end_at
      unless public_start_at < public_end_at
        errors.add :public_end_at, "は公開開始日以降の日付を設定してください。"
      end
    end
  end

  def self.permit_select
    PERMIT_LABEL.collect{|key, value| [key, value]}
  end

  def self.delivery_dates_select
    DELIVERY_DATE.collect{|key, value| [key, value]}
  end

  def delivery_dates_label
    DELIVERY_DATE.index self.delivery_dates
  end

  def permit_label
    permit_labels = Hash.new
    PERMIT_LABEL.each { |key, value| permit_labels[value] = key }
    permit_labels[self.permit]
  end

  alias :small_resource_old= :small_resource=
  alias :medium_resource_old= :medium_resource=
  alias :large_resource_old= :large_resource=
  [:small_resource , :medium_resource , :large_resource].each do  | method_name|
    define_method("#{method_name}=") do | value |
      if value.class == ActionController::UploadedStringIO || value.class == ActionController::UploadedTempfile || value.class == Tempfile
        image_resource = ImageResource.new_file(value, value.original_filename)
        self.send "#{method_name}_old=".intern, image_resource
      elsif value.class == ImageResource
        self.send "#{method_name}_old=".intern, value
      else
        nil
      end
    end
  end

  # 規格
  def first_product_style
    product_styles.empty? and return nil
    product_styles[0]
  end
  delegate_to :first_product_style, :style_category1, :style, :as => :style1
  delegate_to :first_product_style, :style_category2, :style, :as => :style2
  delegate_to :first_product_style, :style_category1, :style_id, :as => :style_id1
  delegate_to :first_product_style, :style_category2, :style_id, :as => :style_id2

  # 最安値と最高値の 2 要素配列
  def price_range
    [product_styles.minimum(:sell_price), product_styles.maximum(:sell_price)]
  end

  def price_label
    p_range = price_range
    if p_range[0] == p_range[1]
      number_with_delimiter(p_range[0])
    else
      p_range.map{|p| number_with_delimiter(p)}.join("～")
    end
  end

  def category_name
    self.category && self.category.name
  end
  def supplier_name
    self.supplier && self.supplier.name
  end
  def retailer_name
    self.retailer && self.retailer.name
  end
  # 送料無料？
  def free_delivery?
    statuses.exists?(['name=?', '送料無料'])
  end

  def permit_select_tag
    PERMIT_LABEL.map{|key, value| "<option value=#{value}#{" selected=""selected""" if value == self.permit }>#{key}</option>" }.join
  end

#  # 購入可能？
#  def can_be_bought?(now=Time.zone.now)
#    permit && in_sale_term?(now) # TODO: have_zaiko? も入れて良い？
#  end

  # 販売期間内
  def in_sale_term?(now=Time.now)
    sale_start_at <= now && now <= (sale_end_at + 1.day - 1 )
  end

  # 公開期間内
  def in_public_term?(now=Time.now)
    public_start_at <= now && now <= (public_end_at + 1.day  - 1)
  end
  # 在庫がある
  def have_zaiko?
    product_styles or return false
    product_styles.any? do |ps|
      #販売可能数で判断
      ps.orderable_count.to_i > 0
    end
  end

  def self.default_condition
    conditions = [["products.permit = ?", true]]
    conditions << ["? between products.public_start_at and products.public_end_at", today_utc(Date.today)]
    conditions << ["have_product_style = ?", true]
    conditions
  end

  def self.get_conditions(search, params, actual_count_list_flg = false)
    search_list = []
    if search
      unless search.product_id.blank?
        if search.product_id.to_s =~ /^\d*$/
          if search.product_id.to_i < 2147483647
            search_list << ["products.id = ?", search.product_id.to_i]
          else
            search_list << ["products.id = ?", 0]
          end
        else
          search.errors.add "商品IDは数字で入力して下さい。", ""
        end
      end
      unless search.code.blank?
        code_condition = ["product_styles.code like ? ", "%#{search.code}%"]
        if actual_count_list_flg
          search_list << code_condition
        else
          product_styles = ProductStyle.find(:all, :select => "product_styles.product_id",
                                             :conditions => code_condition )
          ids = product_styles.map{|p| p.product_id}.join(",")
          ids = id_change_to_i(ids)
          search_list << ["products.id in (?) ", ids]
        end
      end
      unless search.manufacturer.blank?
        code_condition = ["product_styles.manufacturer_id like ? ", "%#{search.manufacturer}%"]
        if actual_count_list_flg
          search_list << code_condition
        else
          product_styles = ProductStyle.find(:all, :select => "product_styles.product_id",
                                             :conditions => code_condition )
          ids = product_styles.map{|p| p.product_id}.join(",")
          ids = id_change_to_i(ids)
          search_list << ["products.id in (?) ", ids]
        end
      end      
      unless search.style.blank?
        product_styles = ProductStyle.find(:all, :select => "product_styles.product_id",
                                           :joins => "left join style_categories  on product_styles.style_category_id1 = style_categories.id left join style_categories as style_categories2 on style_category_id2 = style_categories2.id ",
                                           :conditions => ["style_categories.name like ? or style_categories2.name like ? ", "%#{search.style}%", "%#{search.style}%"] )
        ids = product_styles.map{|p| p.product_id}.join(",")
        ids = id_change_to_i(ids)

        search_list << ["products.id in (?)", ids]
      end
      unless search.name.blank?
        search_list << ["products.name like ?", "%#{search.name}%"]
      end
      unless search.supplier.blank?
        search_list << ["products.supplier_id = ?", search.supplier.to_i]
      end      
      unless search.category.blank?
        category = Category.find_by_id search.category.to_i
        unless category.blank?
          ids = category.get_child_category_ids
          search_list << ["products.category_id in (?)", ids] unless ids.empty?
        end
      end
      unless search.permit.blank?
        search_list << ["products.permit = ?", search.permit]
      end
      unless search.created_at_from.blank?
        if actual_count_list_flg
          search_list << ["product_styles.created_at >= ?", search.created_at_from]
        else
          search_list << ["products.created_at >= ?", search.created_at_from]
        end
      end
      unless search.created_at_to.blank?
        if actual_count_list_flg
          search_list << ["product_styles.created_at < ?", search.created_at_to + 1 * 60 * 60 * 24]
        else
          search_list << ["products.created_at < ?", search.created_at_to + 1.day]
        end
      end
      unless search.updated_at_from.blank?
        if actual_count_list_flg
          search_list << ["product_styles.updated_at >= ?", search.updated_at_from]
        else
          search_list << ["products.updated_at >= ?", search.updated_at_from]
        end
      end
      unless search.updated_at_to.blank?
        if actual_count_list_flg
          search_list << ["product_styles.updated_at <= ?", search.updated_at_to ]
        else
          search_list << ["products.updated_at <= ?", search.updated_at_to + 1.day]
        end
      end
      unless search.sale_start_at_start.blank?
        search_list << ["products.sale_start_at >= ?", search.sale_start_at_start]
      end
      unless search.sale_start_at_end.blank?
        search_list << ["products.sale_start_at <= ?", search.sale_start_at_end + 1.day]
      end
      unless search.retailer_id.blank?
        search_list << ["products.retailer_id = ?", search.retailer_id]
      end
    end
    unless params["product_status_ids"].blank?
      product_status = ProductStatus.find(:all, :select => "distinct product_id",  :conditions => "status_id IN (#{ params["product_status_ids"].join(",") })" )
      ids = product_status.map{|p| p.product_id||0}.join(",")
      ids = id_change_to_i(ids)
      search_list << ["products.id in (?)", ids]
    end
    [search, search_list]
  end

  def self.csv(search_list)
    products = self.find(:all,
                         :conditions => flatten_conditions(search_list),
                         :include => DEFAULT_INCLUDE,
                         :order => "products.id")
    csv_text = CSVUtil.make_csv_string(csv_rows(products), csv_header)
    [csv_text, csv_filename]
  end

  def self.actual_count_list_csv(search_list)
    products = ProductStyle.find(:all,
                                  :conditions => flatten_conditions(search_list),
                                  :joins => "LEFT JOIN products ON products.id = product_styles.product_id ",
                                  :order => "id")
    rows = actual_count_list_csv_rows(products)
    csv_text = CSVUtil.make_csv_string(rows, actual_count_list_csv_header)
    [csv_text, actual_count_list_csv_filename]
  end

  def master_shop?
    return retailer_id == Retailer::DEFAULT_ID
  end

  class << self
    def add_by_csv(filepath, retailer_id)
      line = 0
      Product.transaction do
        CSV.foreach(filepath, encoding: Encoding::Shift_JIS) do |row|
          if line != 0
            product = new_by_array(row, retailer_id)
            if product.nil?
              return [line-1, false]              
            end
            unless product.save!
              return [line-1, false]
            end
          end
          line = line + 1
        end
      end
      [line - 1, true]
    end

    private

    def new_by_array(arr, retailer_id)
      arr.map! do | val |
        Iconv.conv('UTF-8', 'cp932', val)
      end
      # retailer_idの確認
      product = Product.find_by_id(arr[0].to_i) unless arr[0].blank?
      if retailer_id != Retailer::DEFAULT_ID && product && product.retailer_id != retailer_id
        return nil
      end
      #arr[0]が対応しているデータ存在する時、更新、存在しない時、新規作成
      unless product
        product = Product.new
      end
      #CSVデータ設定
      set_data(product,arr,retailer_id)
      product
    end

    #CSVデータ設定
    def set_data(product,arr,retailer_id)
      setPermit(product, arr[1])
      product.name = arr[2]
      product.url = arr[3]
      product.introduction = arr[4]
      product.description = arr[5]
      product.key_word = arr[6]
      product.price = arr[7]
      setImageId(product,arr)
      product.small_resource_comment = arr[9]
      product.medium_resource_comment = arr[12]
      product.large_resource_comment = arr[15]
      product.sell_limit = arr[17]
      product.point_granted_rate = arr[18]
      product.sale_start_at = arr[19]
      product.sale_end_at = arr[20]
      setCategoryId(product, arr[21])
      product.arrival_expected_date = arr[22]
      product.size_txt = arr[23]
      product.material = arr[24]
      product.origin_country = arr[25]
      product.weight = arr[26]
      product.arrival_date = arr[27]
      product.other = arr[28]
      product.free_comment = arr[29]
      setDelivery_dates(product,arr[30])
      setSupplierId(product,arr[31])
      # todo: csvupload retailer対応
      if retailer_id == Retailer::DEFAULT_ID
        setRetailerId(product,arr[32])
      else
        setRetailerId(product,arr[32],retailer_id)
      end
    end

    def setPermit(product, permit)
      if permit == "公開"
        product.permit = true
      else
        product.permit = false
      end
    end

    def setDelivery_dates(product, delivery_dates_label)
      product.delivery_dates = DELIVERY_DATE[delivery_dates_label] unless delivery_dates_label.blank?
    end
    def setSupplierId(product, s_name)
      if s_name.blank?
        product.supplier_id = Supplier::DEFAULT_SUPPLIER_ID
      else
        s = Supplier.find_by_name(s_name)
        if !s.blank?
          product.supplier_id = s.id
        else
          raise ActiveRecord::RecordNotFound 
        end        
      end
    end

    def setRetailerId(product, name, retailer_id = nil)
      if name.blank? && retailer_id.nil?
        product.retailer_id = Retailer::DEFAULT_ID
      elsif retailer_id
        product.retailer_id = retailer_id
      else
        r = Retailer.find_by_name(name)
        if !r.blank?
          product.retailer_id = r.id
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end
    #画像データセット
    def setImageId(product,arr)
      #画像IDと画像パスの項目を別々に設定して画像パスがあった場合は、その先にある画像を登録し、なかった場合は画像IDを登録する
      #指定パスの画像が存在ない時も画像IDを登録する
      if arr[10].blank?
        small_resource_id = arr[8]
      else
        small_resource_id = get_image_resource_seq(arr[10])
        if small_resource_id.blank?
          small_resource_id = arr[8]
        end
      end

      if arr[13].blank?
        medium_resource_id = arr[11]
      else
        medium_resource_id = get_image_resource_seq(arr[13])
        if medium_resource_id.blank?
          medium_resource_id = arr[11]
        end
      end

      if arr[16].blank?
        large_resource_id = arr[14]
      else
        large_resource_id = get_image_resource_seq(arr[16])
        if large_resource_id.blank?
          large_resource_id = arr[14]
        end
      end
      product.small_resource_id = small_resource_id
      product.medium_resource_id = medium_resource_id
      product.large_resource_id = large_resource_id
    end

    def setCategoryId(product, catName)
      c = Category.find_by_name(catName)
      product.category_id = c.id
    end

    #画像データをDB登録
    def get_image_resource_seq(image_path)
      #常用画像タイプ
      format = [".gif",".jpg",".jpeg",".jpe",".jfif",".png",".tif",".tiff",".bmp"]
      #画像ファイル存在しない時、画像登録しない
      if !image_path.blank? && format.include?(File.extname(image_path).downcase) && FileTest.exist?(image_path)

        resource = ImageResource.new
        resource.name = File.basename(image_path)
        resource.content_type = get_content_type(File.extname(image_path).downcase)
        resource.save

        File.open(image_path,'rb') { |file|
          ResourceData.create(:resource_id => resource.id, :content => file.read)
        }
        resource.id
      end
    end
    #content_type設定
    def get_content_type(extname)
      type = extname[1,extname.length-1]
      base = "image/"
      type_g = ["gif"]
      type_j = ["jpg","jpeg","jpe","jfif"]
      type_p = ["png"]
      type_t = ["tif","tiff"]
      type_b = ["bmp"]
      if type_g.include?(type)
        sub_type = "gif"
      elsif type_j.include?(type)
        sub_type = "jpeg"
      elsif type_p.include?(type)
        sub_type = "png"
      elsif type_t.include?(type)
        sub_type = "tiff"
      elsif type_b.include?(type)
        sub_type = "bmp"
      else sub_type = ""
      end
      base << sub_type
    end
  end

  private
  def self.csv_columns_name
    [
      :id ,
      :permit,
      :name,
      :url,
      :introduction,
      :description,
      :key_word,
      :price,
      :small_resource_id,
      :small_resource_comment,
      :small_resource_path,
      :medium_resource_id,
      :medium_resource_comment,
      :medium_resource_path,
      :large_resource_id,
      :large_resource_comment,
      :large_resource_path,
      :sell_limit,
      :point_granted_rate,
      :sale_start_at,
      :sale_end_at,
      :category_name,
#      :category_id,
      :arrival_expected_date,
      :size_txt,
      :material,
      :origin_country,
      :weight,
      :arrival_date,
      :other,
      :free_comment,
      :delivery_dates_label,
      :supplier_name,
      :retailer_name,
      :created_at,
      :updated_at
    ]
  end

  def self.set_field_names
    {
      :id => "商品ID",
      :permit => "公開設定",
      :name => "名前",
      :url => "参照URL",
      :introduction => "一覧コメント",
      :description => "詳細コメント",
      :key_word => "キーワード",
      :price => "参考市場価格",
      :small_resource_id => "一覧・メイン画像ID",
      :small_resource_comment => "一覧・メイン画像コメント",
      :small_resource_path => "一覧・メイン画像パス",
      :medium_resource_id => "詳細・メイン画像ID",
      :medium_resource_comment => "詳細・メイン画像コメント",
      :medium_resource_path => "詳細・メイン画像パス",
      :large_resource_id => "詳細・メイン拡大画像ID",
      :large_resource_comment => "詳細・メイン拡大画像コメント",
      :large_resource_path => "詳細・メイン拡大画像パス",
      :sell_limit => "購入制限",
      :point_granted_rate => "ポイント付与率",
      :sale_start_at => "販売開始日",
      :sale_end_at => "販売終了日",
      :category_name => "商品カテゴリ",
      :arrival_expected_date => "入荷予定日",
      :size_txt => "サイズ",
      :material => "素材",
      :origin_country => "原産国",
      :weight => "重さ",
      :arrival_date => "入荷日",
      :other => "その他仕様",
      :free_comment => "フリー入力",
      :delivery_dates_label => "配送日",
      :supplier_name => "仕入先名",
      :retailer_name => "販売元名",
      :created_at => "登録日",
      :updated_at => "更新日"
    }
  end

  def self.csv_header
    csv_columns_name.map{|name| set_field_names[name] }
  end

  def self.csv_filename
    "product_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def self.csv_rows(products)
    return if products.blank?
    products.map do |product|
      csv_columns_name.map do |column|
        if column.to_s == "permit"
          if product[column]
            "公開"
          else
            "非公開"
          end
        elsif column.to_s == "delivery_dates_label"
          product.delivery_dates_label
        elsif ![:small_resource_path,:medium_resource_path,:large_resource_path,:category_name,:delivery_dates_label,:supplier_name,:retailer_name].include?(column)&& Product.columns_hash[column.to_s].class == :datetime
          (product[column] + (60*60*9)).strftime("%Y-%m-%d %H:%M") if product[column]
        else
          product[column] || product.send(column)
        end
      end
    end
  end

  def self.actual_count_list_csv_header
    %w( 商品名 商品コード 登録更新日 実在個数 )
  end

  def self.actual_count_list_csv_filename
    "actual_count_list_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def self.actual_count_list_csv_rows(products)
    return if products.blank?
    products.map do |product|
      [
        product.product_name,
        product.code,
        product.updated_at,
        product.actual_count.to_i
      ]
    end
  end

  def self.id_change_to_i(ids)
    if ids.blank?
      ids = 0
    else
      ids = ids.split(/\s*,\s*/)
    end
    ids
  end

  def self.today_utc(today)
    ud = Time.local(today.year,today.month,today.day)
    DateTime.new(ud.year, ud.month, ud.day, ud.hour, ud.min, ud.sec)
  end
end
