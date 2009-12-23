# -*- coding: utf-8 -*-
require 'csv'
module AddCSVDownload
  module ClassMethods
    include ActiveRecordHelper
    DEFAULT_LIST_VIEW = ["id", "created_at", "updated_at", "name", "position"]
    DEFAULT_SEARCH = {"id" => :text,  "name" => :text}

    def list_for_csv(params)
      prepare(params)
      options = @find_options.reject do |key,_|
        [:page, :per_page].include? key
      end
      @records = @model.find(:all, options)
    end
    
    def csv(params)
      list_for_csv(params)
      columns, titles = get_csv_settings((@model.nil? ? nil : @model.csv_columns_name))
      f = StringIO.new('', 'w')
      CSV::Writer.generate(f) do | writer |
        writer << titles
        @records and @records.each do | record |
          writer << columns.map do | column |
            record[column] || record.send(column)
          end
        end
      end
      filename = "#{csv_output_setting_name}#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"      
      [f.string, filename]
    end

    private

    def prepare(params)
      @model_name = model_name
      @model = eval @model_name.classify
      prepare_before(params)
      prepare_after(params)
    end

    def prepare_before(params)
      get_list_view
      get_order
      get_conditions(params)
    end
    
    def prepare_after(params)
      per_page = params[:search] && params[:search][:per_page]
      per_page ||= params[:per_page]
      per_page ||= 10
      @find_options = {
        :page => params[:page],
        :per_page => per_page,
        :conditions => flatten_conditions(@search_list), 
        :order => @order
      }
    end

    def get_list_view(list_view_str = nil )
      list_view_str ||= list_view_data if defined? list_view_data
      list_view_str ||= self.class::VIEW_COLUMNS if defined? self.class::VIEW_COLUMNS
      list_view_str ||= DEFAULT_LIST_VIEW
      
      @list_view = []
      list_view_str.each do | column |
        if @model.columns_hash[column]
          @list_view << column
        end
      end
    end

    def get_order
      if defined? order
        @order = order
      end
      @order ||= @model.table_name + ".id"
    end

    def get_conditions(params)
      @year = Hash.new
      @month = Hash.new
      @day = Hash.new
      @search_list = []
      if params[:search]
        hash = SearchForm.new(params[:search]).attributes
        params[:search].find_all{|k,v| k.include?('.')}.each do |k,v|
          hash[k] = v
        end
        hash.each do | column, value |
          if column =~ /^(search_)?(.*)(_from|_to)(.*)/
            column = $2
            status = $3
            date = $4
          end
          model = @model
          # カラム名に . が含まれるならテーブル名付きで検索
          if column.include?(?.)
            table, column = column.split('.')
            ActiveRecord::Base.connection.table_exists?(table) or next
            model = Object.const_get(table.classify)
          else
            model.columns_hash.include? column or next
          end
          full_name = "%s.%s" % [model.table_name, column]
          
          op = "="
          if status == "_from"
            op = ">="
          elsif status == "_to"
            op = "<="
          end
          case model.columns_hash[column].type.to_s
          when "integer"
            @search_list << ["#{full_name} #{op} ?", value.to_i] unless value.blank?
          when "boolean"
            @search_list << ["#{full_name} #{op} ?", value] unless value.blank?
          when "string", "text"
            if op == "="
              @search_list << ilike_conditions(full_name, value) unless value.blank?
            else
              @search_list << ["#{full_name} #{op} ?", value] unless value.blank?
            end
          when "datetime", "date"
            key = column+status
            if date == "(1i)"
              @year[key] = value
            elsif date == "(2i)"
              @month[key] = value
            elsif date == "(3i)"
              @day[key] = value
            end
            
            time = nil
            if !@year[key].blank? && !@month[key].blank? && !@day[key].blank?
              time = Time.zone.local(@year[key].to_i, @month[key].to_i, @day[key].to_i)
            elsif [Date, Time].any?{|c| value.is_a?(c)}
              time = value
            elsif date.empty? # search[:foo]='1900-01-01 00:00:00' みたいに来た場合
              time = Time.zone.parse(value) # 失敗したときは nil になる
            end

            
            if time && status == "_from"
              @search_list << ["#{full_name} >= ?", time]
            elsif time && status == "_to"
              @search_list << ["#{full_name} < ?", time+(1.day)]
            end
          end
        end
      end
    end    
    
    def get_csv_settings(columns=nil)
      unless columns
        columns = @model.columns.map(&:name)
      end
      titles = columns.map do | name |
        @model.set_field_names[name]
      end
      [columns, titles]
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end

ActiveRecord::Base.instance_eval { include AddCSVDownload }
