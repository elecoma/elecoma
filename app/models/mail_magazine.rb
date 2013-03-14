class MailMagazine < ActiveRecord::Base
  acts_as_paranoid

  def self.get_sql_select
# to_char(c.birthday, 'MM') as birth_month,
<<-EOS
select
c.id,
c.login_id,
c.prefecture_id,
c.sex,
c.receive_mailmagazine,
#{MergeAdapterUtil.convert_time_to_mm('c.birthday')} as birth_month,
#{MergeAdapterUtil.concat('c.family_name', 'c.first_name')} as name_kanji,
#{MergeAdapterUtil.concat('c.family_name_kana', 'c.first_name_kana')} as name_kana,
c.birthday,
c.email,
c.occupation_id,
coalesce(sum_total.total,0) as total,
coalesce(sum_order_count.order_count,0) as order_count,
c.created_at,
c.updated_at,
last_order.last_order_at,
last_order.last_order_code
EOS
  end

  def self.get_sql_condition(condition, except_list = [])
    conditions = []
    sql_condition = <<-EOS
from
customers c

left join (select
o.customer_id,
sum(coalesce(d.total,0)) as total
from
orders o,
order_deliveries d
where
o.id=d.order_id
group by
o.customer_id) sum_total on
c.id=sum_total.customer_id

left join (select
o.customer_id,
count(o.customer_id) as order_count
from
orders o
group by
o.customer_id) sum_order_count on
c.id=sum_order_count.customer_id

left join (select
o.customer_id,
max(received_at) as last_order_at,
max(code) as last_order_code
from
orders o
group by o.customer_id) last_order on
c.id=last_order.customer_id

#{unless condition.campaign_id.blank?
"left join (select customer_id
from campaigns_customers
where campaign_id=#{condition.campaign_id}
group by customer_id) cc"
end}

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
group by o.customer_id) product_info"
end}

where
(c.deleted_at IS NULL OR c.deleted_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}')
and c.activate = 2
#{unless except_list.blank?
    "and c.id not in (#{except_list.join(",")})"
  end}
#{if condition.form_type == "0"
    "and c.receive_mailmagazine <> #{Customer::NO_MAIL}"
  else
    "and c.receive_mailmagazine = #{condition.form_type}"
  end}
#{if condition.mail_type == "0"
    "and c.mobile_carrier = #{Customer::NOT_MOBILE}"
  else
    "and c.mobile_carrier <> #{Customer::NOT_MOBILE}"
  end}
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
    "and #{MergeAdapterUtil.concat('c.family_name', 'c.first_name')} like ? "
  end}
#{unless condition.customer_name_kana.blank?
    condition << "%#{condition.customer_name_kana}%"
    "and #{MergeAdapterUtil.concat('c.family_name_kana', 'c.first_name_kana')} like ? "
  end}
#{if condition.sex_male == "1" && condition.sex_female == "0"
    "and c.sex=1"
  elsif condition.sex_male == "0" && condition.sex_female == "1"
    "and c.sex=2"
  end}
#{unless condition.birth_month.blank?
    "and to_char(c.birthday,'MM')='#{sprintf("%02d",condition.birth_month)}'"
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
#{unless condition.tel_no.blank?
    conditions << "%#{condition.tel_no}%"
    "and #{MergeAdapterUtil.concat('c.tel01', 'c.tel02', 'c.tel03')} like ? "
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
#{unless condition.campaign_id.blank?
  "and c.id=cc.customer_id"
end}
order by c.id
EOS
    return sql_condition, conditions
  end

end
