# To change this template, choose Tools | Templates
# and open the template in the editor.

class GoogleAnalyticsEcommerce < ActiveForm
  attr_accessor :trans
  def initialize
    @trans = nil
    @items = []
  end

  def sync
    ret_val = ""
    ret_val << @trans.sync
    @items.each do |i|
      ret_val << i.sync
    end
    ret_val << "pageTracker._trackTrans();"
    return ret_val
  end

  def async
    ret_val = ""
    ret_val << @trans.async
    @items.each do |i|
      ret_val << i.async
    end
    ret_val << "_gaq.push(['_trackTrans']);"
    return ret_val
  end

  def add_item(item)
    @items << item
  end
end
