# -*- coding: utf-8 -*-

#棚卸用CSV出力
require 'csv'
class Admin::StockCsvController < Admin::BaseController
  before_filter :admin_permission_check_stock
  caches_page :csv

  def index
    pairs = CSVUtil.make_csv_index_pairs(params[:controller], page_cache_directory, page_cache_extension)
    unless pairs
      @dates = []
      @urls = []
      return
    end
    @dates = pairs.map do |_, time|
      time
    end
    @urls = pairs.map do |id, _|
      url_for(:action => :csv, :id => id,:format => "csv")
    end
  end

  def new
    redirect_to(url_for_date(DateTime.now))
  end

  def csv
    # params[:id] はページキャッシュのキーにするだけで抽出条件にはしない
    if params[:id].blank?
      render :status => :not_found
    end
    rows = ProductStyle.find(:all).map do |ps|
      a = []
      a << ps.code
      a << ps.product.name
      a << ps.product.supplier_name
      a << ps.actual_count
      a << ps.broken_count
      a
    end

    name = params[:id]
    filename = '%s.csv' % name
    title = %w(商品コード 商品名 仕入先名 実在庫数 不良在庫数)

    f = CSVUtil.make_csv_string_with_cache(rows, title, params[:controller], page_cache_directory, filename, self.perform_caching)
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => Iconv.conv('cp932', 'UTF-8', f.string)    
  end
  
  private

  def url_for_date(date)
    url_for(:action => :csv, :id => date.strftime('%Y%m%d_%H%M%S'),:format => "csv")
  end  
end
