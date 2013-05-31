# -*- coding: utf-8 -*-
class Order < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :customer
  belongs_to :retailer
  has_many :order_deliveries

  def subtotal
    sum_deliveries :subtotal
  end

  def total
    sum_deliveries :total
  end

  def payment_total
    sum_deliveries :payment_total
  end

  def proceeds
    sum_deliveries :proceeds
  end

  def self.find_sum conditions=''
    OrderDelivery.find_sum conditions
  end

  def after_create
    generate_code
  end

  def self.get_conditions(search, params)
    search_list = []
    search && search.each do |k, v|
      if (k =~ /^order_code/)
        search[k.sub(pattern, 'orders.code')] = v
      end
    end
    sex = params[:sex] || []
    payment_id = params[:payment_id] || []

    if search
      unless search.customer_name.blank?
        search_list << [MergeAdapterUtil.concat("order_deliveries.family_name", "order_deliveries.first_name") + " like ?", "%#{search.customer_name}%"]
      end
      unless search.customer_name_kana.blank?
        search_list << [MergeAdapterUtil.concat("order_deliveries.family_name_kana", "order_deliveries.first_name_kana") + " like ?", "%#{search.customer_name_kana}%"]
      end
      unless search.created_at_from.blank?
        search_list << ["orders.created_at >= ?", search.created_at_from]
      end
      unless search.created_at_to.blank?
        search_list << ["orders.created_at < ?",search.created_at_to  + 1 * 60 * 60 * 24 ]
      end
      unless search.order_code_from.blank?
        search_list << ["orders.code >= ?", search.order_code_from]
      end
      unless search.order_code_to.blank?
        search_list << ["orders.code <= ?", search.order_code_to ]
      end
      unless search.status.blank?
        search_list << ["order_deliveries.status = ? ", search.status.to_i]
      end
      unless search.email.blank?
        search_list << ["order_deliveries.email like ?", "%#{search.email}%"]
      end
      unless search.tel.blank?
        search_list << [MergeAdapterUtil.concat("order_deliveries.tel01", "order_deliveries.tel02", "order_deliveries.tel03") + " like ?", "%#{search.tel}%"]
      end
      unless search.search_birth_from.blank?
        search_list << ["order_deliveries.birthday >= ?", search.search_birth_from]
      end

      unless search.search_birth_to.blank?
        search_list << ["order_deliveries.birthday < ?", search.search_birth_to + 1 * 60 * 60 * 24 ]
      end
      unless search.search_updated_at_from.blank?
        search_list << ["order_deliveries.created_at >= ?", search.search_updated_at_from]
      end
      unless search.search_updated_at_to.blank?
        search_list << ["order_deliveries.created_at < ?", search.search_updated_at_to + 1 * 60 * 60 * 24 ]
      end
      unless search.search_updated_at_from.blank?
        search_list << ["order_deliveries.updated_at >= ?", search.search_updated_at_from]
      end
      unless search.search_updated_at_to.blank?
        search_list << ["order_deliveries.updated_at < ?", search.search_updated_at_to + 1 * 60 * 60 * 24 ]
      end
      unless search.total_from.blank?
        if search.total_from.to_s =~ /^\d*$/
          search_list << ["order_deliveries.total >= ?", search.total_from]
        else
          search.errors.add "購入金額は数字で入力してください。", ""
        end
      end
      unless search.total_to.blank?
        if search.total_to.to_s =~ /^\d*$/
          search_list << ["order_deliveries.total <= ?", search.total_to]
        else
          search.errors.add "購入金額は数字で入力してください。", ""
        end
      end
      unless search.product_code.blank?
        search_list << ["order_details.product_code like ? ", "%#{search.product_code}%"]
      end
      unless search.shipped_at_from.blank?
        search_list << ["order_deliveries.shipped_at >= ?", search.shipped_at_from]
      end
      unless search.shipped_at_to.blank?
        search_list << ["order_deliveries.shipped_at < ?", search.shipped_at_to + 1 * 60 * 60 * 24 ]
      end
      unless search.retailer_id.blank?
        search_list << ["orders.retailer_id = ? ", search.retailer_id]
      end
    end
    search_list << ['order_deliveries.sex in (?)', sex] unless sex.empty?
    search_list << ['order_deliveries.payment_id in (?)', payment_id] unless payment_id.empty?
    [search, search_list, sex, payment_id]
  end

  def self.csv(search_list)
    order_deliveries = OrderDelivery.find(:all,
                         :conditions => flatten_conditions(search_list),
                         :include => OrderDelivery::DEFAULT_INCLUDE,
                         :order => "order_deliveries.id desc")
    csv_text = CSVUtil.make_csv_string(csv_rows(order_deliveries), csv_header)
    [csv_text, csv_filename]
  end

  private

  def self.csv_filename 
    "order_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def self.csv_header
    columns.map{|name| OrderDelivery.set_field_names[name] }
  end

  def self.csv_rows(order_deliveries)
    return if order_deliveries.blank?
    order_deliveries.map do |od|
      OrderDelivery.csv_columns_name.map do |column|
        nodatetime_columns = [ :order_code, :prefecture_name, :occupation_name, :sex_name, :payment_name, :deliv_pref_name, :delivery_trader_name, :delivery_time_name, :status_view, :ticket_code ]
        if nodatetime_columns.include?(column) || OrderDelivery.columns_hash[column.to_s].type != :datetime
          od[column] || od.send(column)
        else
          (od[column] + 9.hours).strftime("%Y-%m-%d %H:%M") if od[column]
        end
      end
    end
  end

  def generate_code
    id_code = ("%04d" % self.id).slice(-4..-1) # レコード ID の下 4 桁
    self.code = created_at.strftime("%Y%m%d%H%M") + id_code
    self.save_without_validation
  end

  def sum_deliveries message
    order_deliveries.map(&message).map(&:to_i).sum
  end
end
