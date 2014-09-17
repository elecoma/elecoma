class ProductSet < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :product
  has_one :product_order_unit
  validates_format_of :product_style_ids, :with => /^(\d+,){0,19}\d+$/
  validates_format_of :ps_counts, :with => /^(\d+,){0,19}\d+$/ 
  delegate_to :product, :name, :as => :product_name


  def validate
      errors.add(:product_style_ids,:ps_counts) if product_style_ids.count(",") != ps_counts.count(",")
  end

  def self.get_conditions(search, params, actual_count_list_flg = false)
    search_list = []
    if search
      unless search.set_id.blank?
        if search.set_id.to_s =~ /^\d*$/
          if search.set_id.to_i < 2147483647
            search_list << ["product_sets.id = ?", search.set_id.to_i]
          else
            search_list << ["product_sets.id = ?", 0]
          end
        else
          search.errors.add(:id,"")
        end
      end
      unless search.name.blank?
        search_list << ["products.name like ?", "%#{search.name}%"]
      end
      unless search.category.blank?
        category = Category.find_by_id search.category.to_i
        unless category.blank?
          ids = category.get_child_category_ids
          search_list << ["products.category_id in (?)", ids] unless ids.empty?
        end
      end
      unless search.created_at_to.blank?
          search_list << ["products.created_at < ?", search.created_at_to + 1.day]
      end
      unless search.updated_at_from.blank?
          search_list << ["products.updated_at >= ?", search.updated_at_from]
      end
      unless search.updated_at_to.blank?
          search_list << ["products.updated_at <= ?", search.updated_at_to + 1.day]
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
    [search, search_list]
  end


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
