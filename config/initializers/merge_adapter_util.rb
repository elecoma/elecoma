# -*- coding: utf-8 -*-
class MergeAdapterUtil
  def self.convert_time_to_yyyymmdd(column)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return "to_char(#{column}, 'YYYYMMDD')"
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "date_format(#{column}, '%%Y%%m%%d')"
    end
  end
  
  def self.convert_time_to_mm(column)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return "to_char(#{column}, 'MM')"
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "date_format(#{column}, '%%m')"
    end
  end

  def self.concat(columns)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return columns.join(" || ")
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "concat(" + columns.join(",") + ")"
    end
  end 

  def self.age(from, to="now()")
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return "age(#{to}, #{from})"
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "from_days(datediff(#{to}, #{from}))"
    end
  end

  def self.interval_second(interval_str)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return "interval '#{interval_str} seconds'"
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "interval #{interval_str} second"
    end
  end

  def self.day_of_week(column)
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      return "extract(dow from #{column})"
    elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
      return "dayofweek(#{column})"
    end
  end    
end
