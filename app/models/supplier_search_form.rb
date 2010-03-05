# -*- coding: utf-8 -*-
# 仕入先マスタ管理で検索条件を格納するフォーム
class SupplierSearchForm < SearchForm
  set_field_names :supplier_id => '仕入先ID'
  set_field_names :email => 'メールアドレス'
  set_field_names :tel_no => '電話番号'
  set_field_names :fax_no => 'ファックス'
  set_field_names :name => '仕入先名'
  set_field_names :contact_name => '担当者名'

  validates_numericality_of :supplier_id, :allow_blank=>true, :message => 'は半角数字のみを入力してください。'
  validates_format_of :email, :with => /[\x1-\x7f]/, :allow_blank => true, :message => 'は半角英数字のみを入力してください。'
  validates_numericality_of :tel_no, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'
  validates_numericality_of :fax_no, :only_integer => true, :allow_blank => true, :message => 'は半角数字のみを入力してください。'

  def self.get_sql_select
  <<-EOS
  select s.*
  EOS
  end

  def self.get_sql_condition(condition)
    conditions = []
    sql_condition = <<-EOS
from
suppliers s
where
(s.deleted_at IS NULL OR s.deleted_at > '#{Time.now.gmtime.strftime("%Y-%m-%d %H:%M:%S")}')
#{unless condition.supplier_id.blank?
    conditions << condition.supplier_id.to_i
    "and s.id = ?"
  end}
#{unless condition.name.blank?
    conditions << "%#{condition.name}%"
    "and s.name like ?"
  end}
#{unless condition.contact_name.blank?
    conditions << "%#{condition.contact_name}%"
    "and s.contact_name like ?"
  end}
#{unless condition.tel_no.blank?
    conditions << "%#{condition.tel_no}%"
    "and (#{MergeAdapterUtil.concat(['s.tel01', 's.tel02', 's.tel03'])}) like ? "
  end}
#{unless condition.fax_no.blank?
    conditions << "%#{condition.fax_no}%"
    "and (#{MergeAdapterUtil.concat(['s.fax01', 's.fax02', 's.fax03'])}) like ? "
  end}  
#{unless condition.email.blank?
    conditions << "%#{condition.email}%"
    "and s.email like ? "
  end}
order by s.id
EOS
  return [sql_condition, conditions] 
  end

end
