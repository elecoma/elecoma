# -*- coding: utf-8 -*-
  def parse_date_select params, name
    return nil unless params and not params['%s(1i)' % name].blank?
    args = (1..3).map {|i| params["%s(%di)" % [name, i]]}.reject(&:blank?).map(&:to_i)
    args << 1 if args.length < 3
    Time.local(*args)
  end

require 'gruff'

class TotalizerBase
end

TotalizerBase.instance_eval { include AddCSVDownload }

# 名前が気にいらない
class Totalizer < TotalizerBase
  COLUMN_NAMES = {
    'term' => '期間',
    'male' => '男性',
    'female' => '女性',
    'member_male' => "男性\n(会員)",
    'member_female' => "女性\n(会員)",
    'guest_male' => "男性\n(非会員)",
    'guest_female' => "女性\n(非会員)",

    'product_code' => '商品番号',
    'product_name' => '商品名',
    'items' => '点数',
    'unit_price' => '単価',
    'price' => '金額(税込)',
    'sale_start_at' => '販売開始期間',

    'age' => '年齢',
    'job' => '職業',
    'kind' => '区分',

    'position' => '順位',
    'count' => '購入件数',
    'sum' => '購入合計',
    'average' => '購入平均',

    'subtotal' => '小計',
    'total' => '購入合計',
    'payment_total' => '支払い合計',
    'discount' => '値引',
    'charge' => '手数料',
    'deliv_fee' => '送料',
    'use_point' => '使用ポイント',
  }
  WHERE_CLAUSE = "orders.received_at between :date_from and :date_to and orders.retailer_id = :retailer_id "

  attr_accessor :columns, :title, :total, :links, :default_type

  def Totalizer.get_instance type
    name = "#{type}_totalizer".classify
    Object.const_defined?(name) and Object.const_get(name).new
  end

  def labels
    columns.map { |i| COLUMN_NAMES[i] }
  end

  def get_records(params)
    conditions = get_conditions params
    return nil unless conditions[:date_from] and conditions[:date_to]
    @records = search(conditions)
  end

  def get_conditions params
    @type = params[:type]
    if params[:search][:by_date]
      date_from = parse_date_select(params[:search], 'date_from')
      date_to = parse_date_select(params[:search], 'date_to')
    else
      date_from = parse_date_select(params[:search], 'month')
      date_to = Time.local(date_from.year, date_from.month, 1) + 1.month - 1.day if date_from
    end
    date_to &&= Time.local(date_to.year, date_to.month, date_to.day, 23, 59, 59)
    { :date_from => date_from, :date_to => date_to, :retailer_id => params[:search][:retailer_id] }
  end

  def self.list_for_csv(params)
    @records = self.new.get_records(params)
  end

  def graph
    nil
  end

  private

  def init_graph(klass)
    g = klass.new(640)
    g.font = Pathname.new(RAILS_ROOT).join('lib', 'sazanami-gothic.ttf').to_s
    g
  end

  def self.get_csv_settings(columns=nil)
    [self.new.columns, self.new.labels.map{|c|c.sub("\n", '')}]
  end

  def self.csv_output_setting_name
    "total"
  end

end

class TermTotalizer < Totalizer
  def initialize
    super
    @title = '期間別集計'
    @columns = %w(term count male female subtotal discount charge deliv_fee total average)
    @links = %w(日別 day 月別 month 年別 year 曜日別 wday 時間別 hour)
    @default_type = 'day'
  end

  def get_conditions params
    conds = super
    @helper = Helper.new(params[:type])
    conds
  end

  def graph
    @records or return nil
    return nil if @records == []
    g = init_graph(Gruff::Line)
    g.title = self.title
    g.data('価格', @records.map{|r| r['total']})
    labels = {}
    # ラベルは適当に間引いて設定
    (0...@records.size).step([@records.size/3, 1].max)[0...-1].each do |i|
      labels[i] = @records[i]['term']
    end
    # 最後のは必ず付ける
    labels[@records.size-1] = @records.last['term']
    g.labels = labels
    return g.to_blob
  end

  def search conditions
    records = OrderDelivery.find_by_sql([<<-EOS, conditions])
      select
        #{@helper.columns 'received_at'},
        '' as term,
        count(*) as count,
        sum(male) as male,
        sum(female) as female,
        sum(member_male) as member_male,
        sum(member_female) as member_female,
        sum(guest_male) as guest_male,
        sum(guest_female) as guest_female,
        sum(total) as total,
        sum(subtotal) as subtotal,
        sum(payment_total) as payment_total,
        sum(discount) as discount,
        sum(deliv_fee) as deliv_fee,
        sum(charge) as charge,
        sum(use_point) as use_point,
        round(avg(total)) as average
      from (
        select
          case when (customers.sex = #{System::MALE} or (customers.sex is null and order_deliveries.sex = #{System::MALE})) then 1 else 0 end as male,
          case when (customers.sex = #{System::FEMALE} or (customers.sex is null and order_deliveries.sex = #{System::FEMALE})) then 1 else 0 end as female,
          case when customers.sex = #{System::MALE} then 1 else 0 end as member_male,
          case when customers.sex = #{System::FEMALE} then 1 else 0 end as member_female,
          case when customers.sex is null and order_deliveries.sex = #{System::MALE} then 1 else 0 end as guest_male,
          case when customers.sex is null and order_deliveries.sex = #{System::FEMALE} then 1 else 0 end as guest_female,
          subtotal, total, payment_total,
          discount, deliv_fee, charge, use_point,
          orders.received_at
        from order_deliveries
          join orders on orders.id = order_deliveries.order_id
          left outer join customers on customers.id = orders.customer_id
        where #{WHERE_CLAUSE}
      ) as t1
      group by term, #{@helper.group_by_clause}
      order by term, #{@helper.group_by_clause}
    EOS
    # 期間
    records.each do | record |
      record.term = @helper.term_of record
    end
    # 歯抜けを埋める
    all_term = @helper.all_term conditions[:date_from], conditions[:date_to]
    record_hash = records.index_by(&:term)
    # term を回して records に無ければ、全部 0 の Hash で埋める
    records = all_term.map do | term |
      if record_hash[term]
        record_hash[term]
      else
        r = Hash.new(0) # デフォルト値0
        r['term'] = term
        r
      end
    end

    # 合計行
    @total = Hash.new(0)
    records.each do | record |
      columns.each do | key |
        total[key] ||= 0
        total[key] += record[key].to_i
      end
    end
    @total['term'] = '合計'
    if @total['count'] != 0
      @total['average'] = @total['total'] / @total['count']
    else
      @total['average'] = 0
    end
    records
  end

  class Helper
    def initialize type
      @type = type || 'day'
      case @type
      when 'day'
        @fields = ['year', 'month', 'day', 'dow']
        @format = '%04d/%02d/%02d(%s)'
      when 'month'
        @fields = ['year', 'month']
        @format = '%02d/%02d月'
      when 'year'
        @fields = ['year']
        @format = '%02d年'
      when 'wday'
        @fields = ['dow']
        @format = '%s曜日'
      when 'hour'
        @fields = ['hour']
        @format = '%d時'
      end
    end

    def group_by_clause
      @fields.join(', ')
    end

    def columns date_column_name
      #offset = "%d" % Time.zone.utc_offset
      dow_column_interval = "%s" % [date_column_name]#+ #{MergeAdapterUtil.interval_second(offset)}" % [date_column_name]
      dow_column = "#{MergeAdapterUtil.day_of_week(dow_column_interval)} as dow"
      @fields.map do | f |
        unless f == 'dow'
          "extract(%s from %s ) as %s" % [f, date_column_name, f]
        else
          dow_column
        end
      end.join(",\n")
    end

    def term_of record
      @format % @fields.map do | f |
        v = record[f]
        f == 'dow' ? %w(日 月 火 水 木 金 土)[v.to_i] : v
      end
    end

    def date_to_record d
      {'year'=>d.year,'month'=>d.month,'day'=>d.day,'dow'=>d.wday}
    end

    def all_term date_from, date_to
      case @type
      when 'day'
        terms = []
        d = date_from
        (( ( date_to - date_from ) / 1.day).ceil ).times do
           terms << term_of(date_to_record(d))
           d = d.advance(:days=>1)
        end

        terms
      when 'month'
        terms = []
        d = date_from
        while d.year < date_to.year || d.month <= date_to.month
          terms << term_of(date_to_record(d))
          d = Time.local(d.year, d.month + 1)
        end
        terms
      when 'year'
        terms = []
        d = date_from
        while d.year <= date_to.year
          terms << term_of(date_to_record(d))
          d = Time.local(d.year + 1)
        end
        terms
      when 'wday'
        (0..6).map{ |dow| term_of({'dow'=>dow}) }
      when 'hour'
        (0..23).map{ |hour| term_of({'hour'=>hour}) }
      end
    end
  end
end

class ProductTotalizer < Totalizer
  def initialize
    super
    @title = '商品別集計'
    @columns = %w(position product_code product_name count items unit_price price sale_start_at)
    @links = %w(全体 all 会員 member 非会員 nomember)
    @default_type = 'all'
  end
  def get_conditions params
    conds = super
    conds[:activate] =
      case params[:type]
      when 'member'
        [Customer::KARITOUROKU, Customer::TOUROKU, Customer::TEISHI]
      when 'nomember'
        nil
      else
        [Customer::KARITOUROKU, Customer::TOUROKU, Customer::TEISHI]
      end
    @member = params[:type]
    conds[:sale_start_from] = parse_date_select(params[:search], 'sale_start_from')
    conds[:sale_start_to] = parse_date_select(params[:search], 'sale_start_to')
    conds
  end
  def graph
    @records or return nil
    g = init_graph(Gruff::Pie)
    g.title = self.title
    g.legend_box_size = g.legend_font_size = 14
    g.zero_degree = -90.0
    g.sort = false
    others = 0
    @records.each_with_index do |r, i|
      if i < 6
        g.data(r['product_name'], r['price'].to_i)
      else
        others += r['price'].to_i
      end
    end
    if others > 0
      g.data('その他', others)
    end
    return g.to_blob
  end
  def search conditions
    records = OrderDetail.find_by_sql([<<-EOS, conditions])
      select
        1 as position,
        product_code,
        product_name,
        count(*) as count,
        sum(quantity) as items,
        order_details.price as unit_price,
        sum(order_details.price*quantity) as price,
        products.sale_start_at as sale_start_at
      from order_details
        join order_deliveries on order_deliveries.id = order_details.order_delivery_id
        join orders on orders.id = order_deliveries.order_id
        left outer join customers on customers.id = orders.customer_id
        join product_styles on product_styles.id = order_details.product_style_id
        join products on products.id = product_styles.product_id
      where #{WHERE_CLAUSE}
        #{if @member == 'member'
          " and (customers.activate in (:activate)) "
        elsif @member == 'nomember'
          " and (customers.activate is null) "
        else
          " and (customers.activate in (:activate) or customers.activate is null) "
        end}
        and ((:sale_start_from is null or :sale_start_to is null)
             or products.sale_start_at between :sale_start_from and :sale_start_to)
        and product_styles.deleted_at is null
      group by product_code, product_name, unit_price, products.sale_start_at
      order by price desc
    EOS
    # position の振り直し & 販売開始日を Date に
    records.zip((1..records.size).to_a) do | r, i |
      r.position = i
      r.sale_start_at = Date.parse(r.sale_start_at)
    end
    records
  end
end

class AgeTotalizer < Totalizer
  # 上限, 表示名
  AGES = [
    [nil, '未回答'],
    [10, '0～9歳'],
    [20, '10～19歳'],
    [30, '20～29歳'],
    [40, '30～39歳'],
    [50, '40～49歳'],
    [60, '50～59歳'],
    [70, '60～69歳'],
    [:else, '70歳～']
  ]
  def initialize
    super
    @title = '年代別集計'
    @columns = %w(age count subtotal discount charge deliv_fee total average)
    #@links = %w(全体 all 会員 member 非会員 nomember)
    @links = %w(全体 all) # 今のところ非会員購入はできないので
    @default_type = 'all'
  end
  def get_conditions params
    conds = super
    conds
  end
  def graph
    @records or return nil
    g = init_graph(Gruff::SideBar)
    g.title = self.title
    g.sort = false
    @records.each do |r|
      g.data(r['age'], r['payment_total'].to_i)
    end
    g.labels = {0=>' '}
    return g.to_blob
  end
  def search conditions
    age_when_else = AGES.map do | v, label |
      if v == :else
        "else '%s'" % label
      elsif v.nil?
        "when ((customers.birthday is null and customers.id is not null) or (customers.id is null and order_deliveries.birthday is null)) then '%s'" % label
      else
        "when extract(year from #{MergeAdapterUtil.age('customers.birthday')}) < %d then '%s'" % [v, label]
        "when extract(year from #{MergeAdapterUtil.age('order_deliveries.birthday')}) < %d then '%s'" % [v, label]
      end
    end.join("\n")
    records = OrderDetail.find_by_sql([<<-EOS, conditions])
      select
        age,
        count(*) as count,
        sum(total) as total,
        sum(subtotal) as subtotal,
        sum(payment_total) as payment_total,
        sum(discount) as discount,
        sum(deliv_fee) as deliv_fee,
        sum(charge) as charge,
        sum(use_point) as use_point,
        round(avg(total)) as average
      from (
        select
          case
            #{age_when_else}
          end as age,
          total,
          subtotal,
          payment_total,
          discount,
          deliv_fee,
          charge,
          use_point
        from order_deliveries
          join orders on orders.id = order_deliveries.order_id
          left outer join customers on customers.id = orders.customer_id
        where #{WHERE_CLAUSE}
      ) as t1
      group by age
      order by age
    EOS
    # 整列する
    record_hash = records.index_by(&:age)
    AGES.map{|_, age| record_hash[age] || Hash.new(0).merge('age'=>age) }
  end
end

class JobTotalizer < Totalizer
  def initialize
    super
    @title = '職業別集計'
    @columns = %w(position job count subtotal discount charge deliv_fee total average)
    @links = %w(全体 all)
    @default_type = 'all'
  end
  def get_conditions params
    conds = super
  end
  def graph
    @records or return nil
    g = init_graph(Gruff::Pie)
    g.title = self.title
    @records.reject{|r| r['payment_total'].to_i.zero?}.each do |r|
      g.data(r['job'], r['payment_total'].to_i)
    end
    return g.to_blob
  end
  def search conditions
    records = OrderDetail.find_by_sql([<<-EOS, conditions])
      select
        1 as position,
        occupations.name as job,
        count(*) as count,
        sum(total) as total,
        sum(subtotal) as subtotal,
        sum(payment_total) as payment_total,
        sum(discount) as discount,
        sum(deliv_fee) as deliv_fee,
        sum(charge) as charge,
        sum(use_point) as use_point,
        round(avg(total)) as average
      from 
      ( select 
        case
          when customers.occupation_id is not null then customers.occupation_id
          when customers.occupation_id is null then order_deliveries.occupation_id
        end as occupation_id,
        total as total,
        subtotal as subtotal,
        payment_total as payment_total,
        discount as discount,
        deliv_fee as deliv_fee,
        charge as charge,
        use_point as use_point
      from order_deliveries
        join orders on orders.id = order_deliveries.order_id
        left outer join customers on customers.id = orders.customer_id
        left join occupations on occupations.id = customers.occupation_id
      where #{WHERE_CLAUSE}
      ) as t1
        left join occupations on occupations.id = t1.occupation_id
      group by occupations.name
      order by total desc
    EOS
    record_hash = records.index_by(&:job)
    records = Occupation.find(:all).map do | occupation |
      job = occupation.name
      if record_hash.has_key?(job)
        record_hash[job]
      else
        h = Hash.new(0)
        h['job'] = job
        h
      end
    end.sort_by do |record|
      -record['total'].to_i
    end
    records.zip((1..records.size).to_a) do | r, i |
      r['position'] = i
    end
    records
  end
end

class MemberTotalizer < Totalizer
  def initialize
    super
    @title = '会員別集計'
    @columns = %w(kind count subtotal discount charge deliv_fee total average)
  end
  def get_conditions params
    conds = super
  end
  def graph
    @records or return nil
    g = init_graph(Gruff::Pie)
    g.title = self.title
    @records.reject{|r| r['payment_total'].to_i.zero?}.each do |r|
      g.data(r['kind'], r['payment_total'].to_i)
    end
    return g.to_blob
  end
  def search conditions
    records = OrderDetail.find_by_sql([<<-EOS, conditions])
      select
        case when customers.sex = #{System::MALE} then '会員男性'
             when customers.sex = #{System::FEMALE} then '会員女性'
             when customers.sex is null and order_deliveries.sex = #{System::MALE} then '非会員男性'
             when customers.sex is null and order_deliveries.sex = #{System::FEMALE} then '非会員女性'
        end as kind,
        count(*) as count,
        sum(total) as total,
        sum(subtotal) as subtotal,
        sum(payment_total) as payment_total,
        sum(discount) as discount,
        sum(deliv_fee) as deliv_fee,
        sum(charge) as charge,
        sum(use_point) as use_point,
        round(avg(total)) as average
      from order_deliveries
        join orders on orders.id = order_deliveries.order_id
        left outer join customers on customers.id = orders.customer_id
      where #{WHERE_CLAUSE}
      group by kind
      order by total desc
    EOS
    record_hash = records.index_by(&:kind)

    # TODO: ここの即値はなんとかしたい
    records = %w(会員男性 会員女性 非会員男性 非会員女性).map do |kind|
      if record_hash.has_key?(kind)
        record_hash[kind]
      else
        h = Hash.new(0)
        h['kind'] = kind
        h
      end
    end.sort_by do |record|
      -record['total'].to_i
    end
  end
end
