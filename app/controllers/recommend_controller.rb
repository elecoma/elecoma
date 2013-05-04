class RecommendController < ApplicationController
  def tsv
    conditions = Product.default_condition
    @products = Product.find(:all, :conditions => flatten_conditions(conditions))
    csv_data = CSV.generate("",:col_sep => "\t",:row_sep => "\r\n") do | writer |
      writer << [:item_code, :name, :url, :stock_flg, :comment, :category, :area, :price, :img_url]
      @products.each do | product |
        columns = []
        columns << product.id 
        columns << product.name 
        columns << url_for(:controller => "/products", :action => "show", :id => product.id )
        columns << (product.have_zaiko? ? 2 : 0)
        columns << product.introduction.gsub(/(\r\n|[\r\n])/, " ")
        columns << nil
        columns << nil
        columns << product.price_label
        columns << url_for(:controller => "/image_resource", :action => "show", :id => product.small_resource_id) 
        writer << columns 
      end
    end
    filename = "tsv.tsv"
    send_csv(csv_data,filename)
  end
end
