# -*- coding: utf-8 -*-
# 顧客管理で検索条件を格納するフォーム
class CustomerSearchForm < SearchForm
  set_field_names :customer_id => '顧客コード'
  set_field_names :customer_name_kana => '顧客名（カナ）'
  set_field_names :email => 'メールアドレス'
  set_field_names :tel_no => '電話番号'
  set_field_names :total_up => '購入金額(前半)'
  set_field_names :total_down => '購入金額(後半)'
  set_field_names :order_count_up => '購入回数(前半)'
  set_field_names :order_count_down => '購入回数(後半)'
  set_field_names :birthday_from => '誕生日(前半)'
  set_field_names :birthday_to => '誕生日(後半)'
  set_field_names :updated_at_from => '登録・更新日(前半)'
  set_field_names :updated_at_to => '登録・更新日(後半)'
  set_field_names :last_order_from => '最終購入日(前半)'
  set_field_names :last_order_to => '最終購入日(後半)'
  set_field_names :product_code => '購入商品コード'

  validates_numericality_of :customer_id, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_format_of :customer_name_kana, :with => System::KATAKANA_PATTERN, :allow_blank => true, :message => 'は全角カタカナを入力してください。'
  validates_format_of :email, :with => /[\x1-\x7f]/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'
  validates_numericality_of :tel_no, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :total_down, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :total_up, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :order_count_down, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :order_count_up, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_format_of :product_code, :with => /^[0-9A-Za-z]+$/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'

  def self.csv(params)
    @condition = self.new(params[:condition] ||= [])
    sql_condition, conditions = get_sql_condition(@condition)
    sql = get_sql_select(true) + sql_condition
    sqls = [sql]
    conditions.each do |c|
      sqls << c
    end
    #customers = Customer.find_by_sql(get_sql_select(true) + get_sql_condition(@condition))
    customers = Customer.find_by_sql(sqls)
    unless customers.size > 0
      return false
    end

    col_names = []
    syms = Customer.get_symbols
    field_names = Customer.field_names
    syms.each do |sym|
      col_names << field_names[sym]
    end
    f = StringIO.new('', 'w')
    CSV::Writer.generate(f) do | writer |
      writer << col_names
      customers.each do |c|
        arr = []
        syms.each do |sym|
          if sym == "sex".to_sym
            if c.send(sym) == 1
              arr << "男性"
            else
              arr << "女性"
            end
          elsif sym == "age".to_sym
            #誕生日から年齢を割り出す
            birthday = c.send("birthday".to_sym)
            arr << self.get_age(birthday)
          else
            arr << c.send(sym)
          end
        end
        writer << arr
      end
    end
    f.string
  end

  #誕生日から年齢を割り出すメソッド
  def self.get_age(birthday)
    unless birthday.blank?
      today = Date.today
      year = today.year.to_i - birthday.year.to_i
      if today.month.to_i > birthday.month.to_i

      elsif today.month.to_i < birthday.month.to_i
        year = year - 1
      elsif today.month.to_i == birthday.month.to_i
        if today.day.to_i >= birthday.day.to_i

        else
          year = year - 1
        end
      end
      return year
    end
  end

  def self.get_sql_select(for_csv=false)
    if for_csv
<<-EOS
select
    c.id,
    c.zipcode01,
    c.zipcode02,
    c.tel01,
    c.tel02,
    c.tel03,
    c.fax01,
    c.fax02,
    c.fax03,
    c.sex,
    c.age,
    c.point,
    c.occupation_id,
    c.prefecture_id,
    c.family_name,
    c.first_name,
    c.family_name_kana,
    c.first_name_kana,
    c.email,
    c.mobile_serial,
    c.activation_key,
    c.password,
    c.address_city,
    c.address_detail,
    c.login_id,
    c.birthday,
    c.activate,
    c.receive_mailmagazine,
    c.mobile_carrier,
    c.black,
    c.deleted_at,
    c.mobile_type,
    c.user_agent,
    c.corporate_name,
    c.corporate_name_kana,
    c.section_name,
    c.section_name_kana,
    c.contact_tel01,
    c.contact_tel02,
    c.contact_tel03,
    c.address_building,
    c.reachable,
    c.mail_delivery_count,
    c.created_at,
    c.updated_at
EOS
    else
<<-EOS
select
c.id,
c.login_id,
c.prefecture_id,
c.sex,
c.activate,
#{MergeAdapterUtil.convert_time_to_mm('c.birthday')} as birth_month,
#{MergeAdapterUtil.concat(['c.family_name', 'c.first_name'])} as name_kanji,
#{MergeAdapterUtil.concat(['c.family_name_kana', 'c.first_name_kana'])} as name_kana,
c.birthday,
c.email,
#{MergeAdapterUtil.concat(['c.tel01', "'-'", 'c.tel02', "'-'", 'c.tel03'])} as tel_no,
c.occupation_id,
coalesce(sum_total.total,0) as total,
coalesce(sum_order_count.order_count,0) as order_count,
c.updated_at,
last_order.last_order_at
EOS
    end
  end

  def self.get_sql_condition(condition)
    conditions = []
    sql_condition = <<-EOS
from
customers c
#{if !condition.retailer_id.blank?
    conditions << "#{condition.retailer_id}"
    "join (select customer_id from orders where retailer_id = ? ) buycustomer on c.id = buycustomer.customer_id "
  end}


left join (select
o.customer_id,
sum(coalesce(d.total,0)) as total
from
orders o,
order_deliveries d
where
o.id=d.order_id
#{if !condition.retailer_id.blank?
    conditions << "#{condition.retailer_id}"
    "and o.retailer_id = ? "
  end}
group by
o.customer_id) sum_total on
c.id=sum_total.customer_id

left join (select
o.customer_id,
count(o.customer_id) as order_count
from
orders o
#{if !condition.retailer_id.blank?
    conditions << "#{condition.retailer_id}"
    "where o.retailer_id = ? "
  end}
group by
o.customer_id) sum_order_count on
c.id=sum_order_count.customer_id

left join (select
o.customer_id,
max(received_at) as last_order_at
from
orders o
#{if !condition.retailer_id.blank?
    conditions << "#{condition.retailer_id}"
    "where o.retailer_id = ? "
  end}
group by o.customer_id) last_order on
c.id=last_order.customer_id

#{if !condition.product_name.blank? || !condition.product_code.blank? || !condition.category_id.blank?
",(select
o.customer_id
from
orders o,
order_deliveries d,
order_details t
where o.id=d.order_id
and d.id=t.order_delivery_id
#{if !condition.product_name.blank?
    conditions << "%#{condition.product_name}%"
    "and t.product_name like ? "
  end}
#{if !condition.product_code.blank?
    conditions << "%#{condition.product_code}%"
    "and t.product_code like ? "
  end}
#{if !condition.category_id.blank?
    "and t.product_category_id =#{condition.category_id}"
  end}
#{if !condition.retailer_id.blank?
    conditions << "#{condition.retailer_id}"
    "and o.retailer_id = ? "
  end}
group by o.customer_id) product_info"
end}

where
(c.deleted_at IS NULL OR c.deleted_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}')
#{if !condition.product_name.blank? || !condition.product_code.blank? || !condition.category_id.blank?
    "and c.id=product_info.customer_id"
  end}

#{unless condition.customer_id.blank?
    "and c.id = #{condition.customer_id}"
  end}
#{unless condition.prefecture_id.blank?
    "and c.prefecture_id = '#{condition.prefecture_id}'"
  end}
#{unless condition.customer_name_kanji.blank?
    conditions << "%#{condition.customer_name_kanji}%"
    "and (#{MergeAdapterUtil.concat(['c.family_name', 'c.first_name'])}) like ? "
  end}
#{unless condition.customer_name_kana.blank?
    conditions << "%#{condition.customer_name_kana}%"
    "and (#{MergeAdapterUtil.concat(['c.family_name_kana', 'c.first_name_kana'])}) like ?"
  end}
#{if condition.sex_male == "1" && condition.sex_female == "0"
    "and c.sex=1"
  elsif condition.sex_male == "0" && condition.sex_female == "1"
    "and c.sex=2"
  end}
#{unless condition.birth_month.blank?
    "and #{MergeAdapterUtil.convert_time_to_mm('c.birthday')}='#{sprintf("%02d",condition.birth_month)}'"
  end}
#{
  from = condition.birthday_from
  to = condition.birthday_to
  unless from.blank? && to.blank?
    if !from.blank? && !to.blank?
      "and (#{MergeAdapterUtil.convert_time_to_yyyymmdd('c.birthday')} >= '#{from.strftime("%Y%m%d")}'
      and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.birthday')} <= '#{to.strftime("%Y%m%d")}')"
    elsif !from.blank?
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.birthday')} >= '#{from.strftime("%Y%m%d")}'"
    else
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.birthday')} <= '#{to.strftime("%Y%m%d")}'"
    end
  end
}
#{unless condition.email.blank?
    conditions << "%#{condition.email}%"
    "and c.email like ? "
  end}
#{if condition.reachable == '1'
    "and c.reachable = '1'"
  end}  
#{unless condition.tel_no.blank?
    conditions << "%#{condition.tel_no}%"
    "and (#{MergeAdapterUtil.concat(['c.tel01', 'c.tel02', 'c.tel03'])}) like ? "
  end}
#{unless condition.occupation_id.blank?
    "and c.occupation_id in ('" << condition.occupation_id.join("','") << "')"
  end}
#{
  from = condition.total_up
  to = condition.total_down
  unless from.blank? && to.blank?
    if !from.blank? && !to.blank?
      "and (total >= #{from} and total <= #{to})"
    elsif !from.blank?
      "and total >= #{from}"
    else
      "and total <= #{to}"
    end
  end
}
#{
  from = condition.order_count_up
  to = condition.order_count_down
  unless from.blank? && to.blank?
    if !from.blank? && !to.blank?
      "and (order_count >= #{from} and order_count <= #{to})"
    elsif !from.blank?
      "and order_count >= #{from}"
    else
      "and order_count <= #{to}"
    end
  end
}
#{
  from = condition.updated_at_from
  to = condition.updated_at_to
  unless from.blank? && to.blank?
    if !from.blank? && !to.blank?
      "and (#{MergeAdapterUtil.convert_time_to_yyyymmdd('c.updated_at')} >= '#{from.strftime("%Y%m%d")}'
      and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.updated_at')} <= '#{to.strftime("%Y%m%d")}')"
    elsif !from.blank?
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.updated_at')} >= '#{from.strftime("%Y%m%d")}'"
    else
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('c.updated_at')} <= '#{to.strftime("%Y%m%d")}'"
    end
  end
}
#{
  from = condition.last_order_from
  to = condition.last_order_to
  unless from.blank? && to.blank?
    if !from.blank? && !to.blank?
      "and (#{MergeAdapterUtil.convert_time_to_yyyymmdd('last_order_at')} >= '#{from.strftime("%Y%m%d")}'
      and #{MergeAdapterUtil.convert_time_to_yyyymmdd('last_order_at')} <= '#{to.strftime("%Y%m%d")}')"
    elsif !from.blank?
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('last_order_at')} >= '#{from.strftime("%Y%m%d")}'"
    else
      "and #{MergeAdapterUtil.convert_time_to_yyyymmdd('last_order_at')} <= '#{to.strftime("%Y%m%d")}'"
    end
  end
}
order by c.id
EOS
  return [sql_condition, conditions] 
  end

end
