# -*- coding: utf-8 -*-
class MergeAdapterUtil
  def self.convert_time_to_yyyymmdd(column)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      "to_char(#{column}, 'YYYYMMDD')"
    when 'MySQL'
      "date_format(#{column}, '%%Y%%m%%d')"
    end
  end
  
  def self.convert_time_to_mm(column)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      "to_char(#{column}, 'MM')"
    when 'MySQL'
      "date_format(#{column}, '%%m')"
    end
  end

  def self.concat(*columns)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      columns.join(' || ')
    when 'MySQL'
      "concat(#{columns.join(',')})"
    end
  end 

  def self.age(from, to="now()")
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      "age(#{to}, #{from})"
    when 'MySQL'
      "from_days(datediff(#{to}, #{from}))"
    end
  end

  def self.interval_second(interval_str)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      "interval '#{interval_str} seconds'"
    when 'MySQL'
      "interval #{interval_str} second"
    end
  end

  def self.day_of_week(column)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      "extract(dow from #{column})"
    when 'MySQL'
      "dayofweek(#{column})"
    end
  end    
end
