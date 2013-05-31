# -*- coding: utf-8 -*-
module Admin::MailMagazineHelper
  NOT_SELECTED = "（未指定）"
  DATE_FORMAT = "%Y-%m-%d"
  
  def selected_check(value)
    if value.blank?
      return NOT_SELECTED
    end
    value
  end
  
  def sex_name(male,female)
    result = ""
    male_selected = false
    if male && male == "1"
      result << "男性&nbsp;"
    end
    if female && female == "1"
      result << "女性"
    end
    if result.blank?
      result = NOT_SELECTED
    end
    result
  end
  
  def form_type_name(form_type)
    if form_type.blank?
      return NOT_SELECTED      
    end
    if form_type == "0"
      return "（両方）"
    else
      return Customer::MAILMAGAZINE_NAMES[form_type.to_i]
    end
  end
  
  def birth_month_name(birth_month)
    if birth_month.blank?
      return NOT_SELECTED
    end
    return birth_month + "&nbsp;月"
  end
  
  def order_count_name(from, to)
    if from.blank? && to.blank?
      return NOT_SELECTED
    elsif from.blank? && !to.blank?
      return NOT_SELECTED + "&nbsp;〜&nbsp;" + number_with_delimiter(to) + "&nbsp;回"
    elsif !from.blank? && to.blank?
      return number_with_delimiter(from) + "&nbsp;回&nbsp;〜&nbsp;" + NOT_SELECTED     
    end
    number_with_delimiter(from) + "&nbsp;回&nbsp;〜&nbsp;" + number_with_delimiter(to) + "&nbsp;回"
  end
  
  def total_name(from, to)
    if from.blank? && to.blank?
      return NOT_SELECTED
    elsif from.blank? && !to.blank?
      return NOT_SELECTED + "&nbsp;〜&nbsp;" + number_to_currency(to) + "&nbsp;円"
    elsif !from.blank? && to.blank?
      return number_with_delimiter(from) + "&nbsp;円&nbsp;〜&nbsp;" + NOT_SELECTED
    end
    number_with_delimiter(from) + "&nbsp;円&nbsp;〜&nbsp;" + number_with_delimiter(to) + "&nbsp;円"    
  end
  
  def mail_type_name(mail_type)
    if mail_type.blank?
      return NOT_SELECTED
    end
    if mail_type == "0"
      return "パソコン用アドレス"
    end
    "携帯用アドレス"
  end
  
  def occupation_names(ids)
    if ids.blank?
      return NOT_SELECTED
    end
    result = ""
    ids.each do |id|
      result << Occupation.find(id).name
      result << "&nbsp;"
    end
    result
  end
  
  def date_selected_check(from, to)
    if from.blank? && to.blank?
      return NOT_SELECTED
    elsif from.blank? && !to.blank?
      return NOT_SELECTED + "&nbsp;〜&nbsp;" + h(to[0,10])
    elsif !from.blank? && to.blank?
      return h(from[0,10]) + "&nbsp;〜&nbsp;" + NOT_SELECTED
    else 
    end
    h(from[0,10]) + "&nbsp;〜&nbsp;" + h(to[0,10])
  end
  
  def templates_select
    templates = MailMagazineTemplate.find(:all,
      :select => "id,form,subject", 
      :order => "updated_at DESC")
    
    result = []
    if templates.blank?
      return result
    end
    templates.each do |t|
      if t.form == MailMagazineTemplate::TEXT
        result << ["【テキスト】" + t.subject, t.id.to_s]
      else
        result << ["【HTML】" + t.subject, t.id.to_s]
      end
    end
    result
  end
end







