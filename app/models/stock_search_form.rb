# -*- coding: utf-8 -*-
# 在庫管理で商品検索条件を格納するフォーム
class StockSearchForm < SearchForm
  set_field_names :product_id => '商品ID'
  set_field_names :code => '商品コード'
  set_field_names :name => '商品名'
  set_field_names :manufacturer => '型番'
  set_field_names :supplier => '仕入先名'
  set_field_names :category => 'カテゴリ'

  validates_numericality_of :product_id, :allow_blank=>true, :message => 'は半角数字のみを入力してください。'
  validates_format_of :code, :with => /^[a-zA-Z0-9]*$/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'
  validates_format_of :manufacturer, :with => /^[a-zA-Z0-9]*$/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'

  def self.get_conditions(search)
    search_list = []
    if search
      #商品ID
      unless search.product_id.blank?
        search_list << ["stock_histories.product_id = ?", search.product_id.to_i]
      end
      #商品コード
      unless search.code.blank?
        ps = ProductStyle.find(:all,:conditions=>"code like '%#{search.code}'")
        ids = []
        ids = ps.map{|p| p.id.to_i} unless ps.blank?
        search_list << ["stock_histories.product_style_id in (?) ", ids] unless ids.blank?        
      end
      #商品名
      unless search.name.blank?
        ps = Product.find(:all,:conditions=>"name like '%#{search.name}'")
        ids = []
        ids = ps.map{|p| p.id.to_i} unless ps.blank?
        search_list << ["stock_histories.product_id in (?) ", ids] unless ids.blank?        
      end      
      #型番
      unless search.manufacturer.blank?
        ps = ProductStyle.find(:all,:conditions=>"manufacturer_id like '%#{search.manufacturer}'")
        ids = []
        ids = ps.map{|p| p.id.to_i} unless ps.blank?
        search_list << ["stock_histories.product_style_id in (?) ", ids] unless ids.blank?        
      end
      #操作者
      unless search.operator.blank?
        search_list << ["stock_histories.admin_user_id = ?", search.operator.to_i]
      end
      #在庫移動日
      unless search.moved_at_from.blank?
        search_list << ["stock_histories.moved_at >= ?", search.moved_at_from]
      end
      unless search.moved_at_to.blank?
        search_list << ["stock_histories.moved_at <= ?", search.moved_at_to]
      end
      unless search.retailer_id.blank?
        search_list << ["products.retailer_id = ?", search.retailer_id]
      end
    end
    search_list
  end
end
