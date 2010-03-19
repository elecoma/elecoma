# -*- coding: utf-8 -*-
# 検索条件を格納する
# 例: @search = SearchForm.new(params[:search])

class SearchForm < ActiveForm
  VALID_NAME = /^[a-zA-Z_][a-zA-Z0-9_]*$/
  include ActiveRecord::Validations
  def validate
    super
    # from <= to etc...
    attributes.each do | name, value |
      value.blank? and next
      if (m = name.match(/_from$/))
        prefix = m.pre_match
        name_to = prefix+'_to'
        from = value
        to = send(name_to)
        next if to.blank?
        # 数字だけの場合数値として比較
        unless [from, to].any?{|v| v =~ /\D/} # 数字以外が含まれていない
          from = from.strftime("%Y%m%d%H%M%S").to_i
          to = to.strftime("%Y%m%d%H%M%S").to_i
        end
        unless from <= to
          errors.add name, 'の範囲指定が不正です。'
          errors.add name_to, 'の範囲指定が不正です。'
        end
      end
    end
  end

  # ActiveForm からコピペして改造
  def attributes
    attributes = instance_variables
    attributes.delete("@errors")
    attributes.inject({}) do |hash, attribute|
      hash[attribute[1..-1]] = instance_variable_get(attribute)
      hash
    end
  end

  def attributes=(hash)
    hash.each do | key, value |
      next if value.nil? || value == ''
      # datetime
      name = key.to_s
      if (m = name.match(/\((\d)i\)$/))
        next if m[1] != '1'
        name = m.pre_match
        if (date = parse_date_select(hash, name))
          send(name+'=', date)
        end
      elsif value.is_a?(String) &&
          value =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/
        # 日時に見える文字列は Date に
        send(name+'=', Time.parse(value))
      else
        send(name+'=', value)
      end
    end if hash
  end

  def method_missing(key, *args)
    begin
      super
    rescue NoMethodError
      name = key.to_s
      if name.size >= 2 && name[-1] == ?= # name =~ /^.+=$/
        # set
        name = name[0, name.size-1]
        value = args.first
        instance_variable_set('@'+name, value) if name =~ VALID_NAME
      else
        # get
        instance_variable_get('@'+name) if name =~ VALID_NAME
      end
    end
  end

  private

  def parse_date_select(params, name)
    arr = (1..6).map do |i|
      params["%s(%di)" % [name, i]]
    end
    if arr.join.blank?
      return
    end
    year,month,day,hour,min,sec = arr

    selected_date = false
    selected_time = false

    if year || month || day
      selected_date = true
    end

    if hour || min || sec
      selected_time = true
    end

    now = DateTime.now
    if selected_date
      if year.blank?
        year = now.year.to_s
      end
      if month.blank?
        if ! day.blank?
          month = now.month.to_s
        elsif year
          month = "1"
        else
          month = now.month.to_s
        end
      end
      if day.blank?
        if year || month
          day = "1"
        else
          day = now.day.to_s
        end
      end
    end

    if selected_time
      if hour.blank?
        hour = "00"
      end
      if min.blank?
        if hour
          min = "00"
        else
          min = now.min.to_s
        end
      end
      if sec.blank?
        if hour || min
          sec = "00"
        else
          sec = now.sec.to_s
        end
      end
    end
    if selected_time
      Time.local(year.to_i,month.to_i,day.to_i,hour.to_i,min.to_i,sec.to_i)
    else
      Time.local(year.to_i,month.to_i,day.to_i)
    end
  end

  ## from ActiveHeart

  class << self
    def set_field_names(field_names = {})
      @field_names = HashWithIndifferentAccess.new unless @field_names
      @field_names.update(field_names)
    end

    alias_method :_human_attribute_name, :human_attribute_name
    def human_attribute_name(attribute_key_name)
      if @field_names && @field_names[attribute_key_name]
        @field_names[attribute_key_name]
      else
        _human_attribute_name(attribute_key_name)
      end
    end

    def field_names
      @field_names
    end

    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(*args)
      name.humanize
    end
  end

end
