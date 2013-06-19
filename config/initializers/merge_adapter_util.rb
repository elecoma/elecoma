# -*- coding: utf-8 -*-
class MergeAdapterUtil
  def self.convert_time_to_yyyymmdd(column)
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      "to_char(#{column}, 'YYYYMMDD')"
    when /MySQL/i
      "date_format(#{column}, '%%Y%%m%%d')"
    end
  end
  
  def self.convert_time_to_mm(column)
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      "to_char(#{column}, 'MM')"
    when /MySQL/i
      "date_format(#{column}, '%%m')"
    end
  end

  def self.concat(*columns)
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      columns.join(' || ')
    when /MySQL/i
      "concat(#{columns.join(',')})"
    end
  end 

  def self.age(from, to="now()")
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      "age(#{to}, #{from})"
    when /MySQL/i
      "from_days(datediff(#{to}, #{from}))"
    end
  end

  def self.interval_second(interval_str)
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      "interval '#{interval_str} seconds'"
    when /MySQL/i
      "interval #{interval_str} second"
    end
  end

  def self.day_of_week(column)
    case ActiveRecord::Base.connection.adapter_name
    when /PostgreSQL/i
      "extract(dow from #{column})"
    when /MySQL/i
      "dayofweek(#{column})"
    end
  end    
end
