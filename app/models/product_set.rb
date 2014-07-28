class ProductSet < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :product
  has_one :product_order_unit

  validates_presence_of :product_id, :product_style_ids, :ps_counts

  validates_format_of :product_style_ids, :with => /(\d+,)*\d+/
  validates_format_of :ps_counts, :with => /(\d+,)*\d+/ 

  delegate_to :product, :name, :as => :product_name

  def get_product_style_ids
    product_style_ids.split(",").map{|ps_id| ps_id.to_i }
  end

  def get_ps_counts
    ps_counts.split(",").map{|ps_c| ps_c.to_i }
  end

  def order(number)
    self.get_product_style_ids.zip(self.get_ps_counts).each do |id, count|
      ps = ProductStyle.find(id)
      ps.order(number*count)
      ps.save
    end
  end

  def is_included?(carts)
    carts.any? do |cart|
      if cart.is_set?
        self == cart.product_order_unit.ps
      end
    end
  end  

  def get_set_list
    sets = []
    get_product_style_ids.zip(get_ps_counts).each do |id, count|
      set = ProductSetStyle.new(:product_style => ProductStyle.find(id),  :quantity => count)
      sets << set
    end
    sets
  end
end
