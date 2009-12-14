module Admin::CustomersHelper
  def get_hassou_name(order_delivery)
    unless order_delivery.status
      return "ステータス不正"
    end
    if order_delivery.status <= OrderDelivery::HASSOU_TEHAIZUMI
      "未発送"
    else
      order_delivery.shipped_at.strftime("%Y/%m/%d") if order_delivery.shipped_at
    end
  end

  def purchase_price(total, point)
    price = total.to_i - point.to_i
    return "￥" + price.to_s
  end
end
