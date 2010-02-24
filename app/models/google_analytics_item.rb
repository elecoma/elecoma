class GoogleAnalyticsItem < ActiveForm
  attr_accessor :order_id  #注文番号
  attr_accessor :sku  #SKU(在庫管理コード)
  attr_accessor :product_name  #商品名
  attr_accessor :category  #商品カテゴリ
  attr_accessor :price  #価格
  attr_accessor :quantity  #数量

  def initialize
    @order_id = nil
    @sku = nil
    @product_name = nil
    @category = nil
    @price = nil
    @quantity = nil

  end

  def sync
    ret_value = "pageTracker._addItem(\""
    ret_value << @order_id
    ret_value << '","'
    ret_value << @sku
    ret_value << "\", \""
    ret_value << @product_name
    ret_value << "\", \""
    ret_value << @category
    ret_value << "\", \""
    ret_value << @price
    ret_value << "\", \""
    ret_value << @quantity
    ret_value << "\");\n"

    return ret_value
  end

  def async
    ret_value = "_gaq.push(['_addItem','"
    ret_value << @order_id
    ret_value << "','"
    ret_value << @sku
    ret_value << "','"
    ret_value << @product_name
    ret_value << "', '"
    ret_value << @category
    ret_value << "', '"
    ret_value << @price
    ret_value << "', '"
    ret_value << @quantity
    ret_value << "']);\n"

    return ret_value
  end

end
