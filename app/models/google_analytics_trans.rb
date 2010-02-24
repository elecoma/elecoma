
class GoogleAnalyticsTrans < ActiveForm
  attr_accessor :order_id        #注文番号
  attr_accessor :affiliate       #アフィリエイトID
  attr_accessor :total           #総合計額
  attr_accessor :tax             #消費税
  attr_accessor :shipping        #送料
  attr_accessor :city            #市区町村名
  attr_accessor :state           #都道府県名
  attr_accessor :country         #国名

  def initialize
    @order_id = nil
    @affiliate = nil
    @total = nil
    @tax = nil
    @shipping = nil
    @city = nil
    @state = nil
    @country = nil
  end

  def sync
    ret_value = "pageTracker._addTrans(\""
    ret_value << @order_id
    ret_value << "\",\""
    ret_value << @affiliate
    ret_value << "\", \""
    ret_value << @total
    ret_value << "\", \""
    ret_value << @tax
    ret_value << "\", \""
    ret_value << @shipping
    ret_value << "\", \""
    ret_value << @city
    ret_value << "\", \""
    ret_value << @state
    ret_value << "\", \""
    ret_value << @country
    ret_value << "\");\n"

    return ret_value
  end

  def async
    ret_value = "_gaq.push(['_addTrans','"
    ret_value << @order_id
    ret_value << "','"
    ret_value << @affiliate
    ret_value << "', '"
    ret_value << @total
    ret_value << "', '"
    ret_value << @tax
    ret_value << "', '"
    ret_value << @shipping
    ret_value << "', '"
    ret_value << @city
    ret_value << "', '"
    ret_value << @state
    ret_value << "', '"
    ret_value << @country
    ret_value << "']);\n"

    return ret_value
    
  end

end
