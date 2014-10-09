class ProductOrderUnit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :product_style
  belongs_to :product_set
  belongs_to :order_delivery
  validates_presence_of :sell_price
  validates_presence_of :product_style_id, :unless => :is_set?
  validates_presence_of :product_set_id, :if => :is_set?

  delegate_to :product_style, :product
  delegate_to :product_set, :product
  delegate_to :product_style, :product, :id, :as => :product_id, :unless => :is_set?
  delegate_to :product_style, :product, :name, :as => :product_name, :unless => :is_set?
  delegate_to :product_set, :product, :id, :as => :product_id, :if => :is_set?
  delegate_to :product_set, :product, :name, :as => :product_name, :if => :is_set?

  def get_ps_count_in_carts(carts, id)
    count = 0
    carts.each do |cart|
      cart.product_order_unit == self and next
      if cart.is_set?
        cart.product_order_unit.ps.get_product_style_ids.zip(cart.product_order_unit.ps.get_ps_counts).each do |ps_id, ps_count|
          if id == ps_id
            count += ps_count*cart.quantity
          end
        end
      else
        if id == cart.product_order_unit.ps.id
            count += cart.quantity
        end
      end
    end
    count
  end

  def available?(carts, quantity)
    if is_set?
      res = product_set.get_product_style_ids.zip(product_set.get_ps_counts).each do |ps_id, ps_count|
        count = get_ps_count_in_carts(carts, ps_id)
        product_style = ProductStyle.find(ps_id)
        while quantity > 0 && product_style.orderable_count.to_i - count < ps_count*quantity
          quantity = quantity - 1
        end
      end
      quantity
    else
      count = get_ps_count_in_carts(carts, product_style.id)
      product_style.available?(quantity + count) - count 
    end
  end

  def sell_name

  set_flag ? product.name : product_style.full_name
  end

  #税込販売額
  def including_tax_sell_price
    sell_price # sell_price は税込み価格
  end

  def is_set?
    set_flag
  end

  def ps
    set_flag ? product_set :  product_style
  end

  def order(number)
    ps.order(number)
    ps.save
  end

end
