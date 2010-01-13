# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  NOT_FOUND_STRING = "不明"

  def link_parameter(name, option)
    param_datas = {}
    #DOCOMOとAUの場合、リンクに日本語のパラメター値が付いている時の文字化けの問題対応
    params.each{ |key, value| param_datas[key.to_sym] = ((request.mobile? && !request.mobile.is_a?(Jpmobile::Mobile::Softbank)) ? value.tosjis : value) }
    option.each{ |key, value| param_datas[key.to_sym] = value }
    link_to name, param_datas
  end

  def h_br(text)
    value = h(text)
    value.freeze # freeze しないと、gsub の中で $1 が tainted になる模様 (Ruby 1.8.5)
    #value.gsub(/(https?:\/\/[\x21-\x7f]+)/){"<a href=\"#{safe_url($1)}\">#{$1}</a>"}.gsub(/(\r\n|[\r\n])/, "<br/>\n")
    value.gsub(/(\r\n|[\r\n])/, "<br/>\n")
  end
  
  def h_apos(text)
	  unless text.blank?
		  text.gsub!(/\r\n|\r|\n/, "<br />")
			text.gsub("\'","&apos;")
    end
  end

  def date(date)
    date && date.strftime("%Y/%m/%d")
  end

  def date_jp(date)
    date && date.strftime("%Y年%m月%d日")
  end

  def date_month_day_jp(date)
    date && date.strftime("%m月%d日")
  end

  def date_time(date_time)
    date_time && date_time.strftime("%Y/%m/%d %H:%M:%S")
  end

  def prefecture_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Prefecture.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

  def occupation_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Occupation.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

  def grouping_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Groupings.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

  def birthday_select(object_name, method, options={}, html_options={})
    defaults = {:start_year=>1900, :end_year=>Date.today.year, :use_month_numbers=>true}
    options = defaults.merge(options)
    date_select(object_name, method, options)
  end

  def authority_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Authority.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

  def category_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Category.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

  def campaign_name(id, not_exist_string=NOT_FOUND_STRING)
    if id.blank?
      return not_exist_string
    end
    begin
      Campaign.find(id).name
    rescue ActiveRecord::RecordNotFound => e
      logger.error e
      not_exist_string
    end
  end

#   def date_select_tag(name, value = nil, options = {})
#     defaults = { :discard_type => true }
#     options  = defaults.merge(options)
#     datetime = value

#     position = { :year => 1, :month => 2, :day => 3}

#     order = (options[:order] ||= [:year, :month, :day])

#     [:day, :month, :year].each { |o| order.unshift(o) unless order.include?(o) }

#     date_or_time_select = ''
#     order.reverse.each do |param|
#       date_or_time_select +=  content_tag(:select, date_select_options(param), { "name" => "#{name}[#{param}]", "id" => "#{name}_#{param}" }.update(options.stringify_keys))
#     end
#     return date_select_options
#   end

#   def date_select_options(type)
#     case type
#     when :year
#       [""]
#     when :month
#       [""]
#     when :day
#       [""]
#     else
#       [""]
#     end
#     []
#   end
end
