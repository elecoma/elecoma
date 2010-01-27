#棚卸用CSV出力
require 'csv'
class Admin::StockCsvController < Admin::BaseController
  before_filter :admin_permission_check_stock
  caches_page :csv

  def index
    dir = Pathname.new(page_cache_directory).join(params[:controller], 'csv')
    unless FileTest.exist?(dir.to_s)
      FileUtils.mkdir_p(dir.to_s)
      @dates = []
      @urls = []
      return
    end

    limit = 1.year.ago
    pairs = dir.enum_for(:each_entry).map do |path|
      dir.join(path)
    end.select do |path|
      path.extname == page_cache_extension or path.extname == '.csv'
    end.map do |path|
      path.basename(path.extname).to_s
    end.map do |id|
      [id, id.to_time(:local)]
    end.select do |_, time|
      time >= limit
    end.sort_by do |_, time|
      time
    end.reverse

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
    date = DateTime.now
    rows = ProductStyle.find(:all).map do |ps|
      a = []
      a << ps.code
      a << ps.product.name
      a << ps.product.supplier_name
      a << ps.actual_count
      a << ps.broken_count
      a
    end

    # CSV に吐く
    f = StringIO.new('', 'w')
    title = %w(商品コード 商品名 仕入先名 実在庫数 不良在庫数)

    CSV::Writer.generate(f) do | writer |
      writer << title
      rows.each do |row|
        writer << row
      end
    end
    name = params[:id]
    filename = '%s.csv' % name
    headers['Content-Type'] = "application/octet-stream; name=#{filename}"
    headers['Content-Disposition'] = "attachment; filename=#{filename}"
    render :text => Iconv.conv('cp932', 'UTF-8', f.string)    
  end

  def url_for_date(date)
    url_for(:action => :csv, :id => date.strftime('%Y%m%d_%H%M%S'),:format => "csv")
  end  
end
