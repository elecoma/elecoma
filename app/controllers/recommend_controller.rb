class RecommendController < ApplicationController
  def tsv
    conditions = Product.default_condition
    @products = Product.find(:all, :conditions => flatten_conditions(conditions))
    tsv_text = CSVUtil::make_tsv_string(tsv_rows(@products), tsv_header)
    send_tsv(tsv_text, tsv_filename)
  end

  private

  def tsv_filename
    'tsv.tsv'
  end

  def tsv_header
    [ :item_code, :name, :url, :stock_flg, :comment, :category, :area, :price, :img_url ]
  end

  def tsv_rows(products)
    products.map do |product|
      columns = []
      columns << product.id 
      columns << product.name 
      columns << url_for(controller: :products, action: :show, id: product.id)
      columns << (product.have_zaiko? ? 2 : 0)
      columns << product.introduction.gsub(/(\r\n|[\r\n])/, " ")
      columns << nil
      columns << nil
      columns << product.price_label
      columns << url_for(controller: :image_resource, action: :show, id: product.small_resource_id) 
      columns 
    end
  end
end
