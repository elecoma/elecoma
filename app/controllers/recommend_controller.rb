class RecommendController < ApplicationController
  def tsv
    conditions = Product.defalt_condition
    @products = Product.find(:all, :conditions => flatten_conditions(conditions))
    f = StringIO.new('', 'w')
    CSV::Writer.generate(f,"\t","\r\n") do | writer |
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
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => f.string
  end
end
