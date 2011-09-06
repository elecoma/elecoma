# -*- coding: utf-8 -*-
require 'csv'
require 'nkf'

class ServiceCooperation < ActiveRecord::Base
  # 定数
  ENABLE_TYPES = {
      true => '有効',
      false => '無効'
  }
  FILE_TYPES = { 
      0 => { :label =>"CSV", :delimiter => "," }, 
      1 => { :label => "TSV", :delimiter => "\t" } 
  }
  ENCODE_TYPES = {
      0 => { :label => "UTF-8", :option => '-w8'},
      1 => { :label => "SHIFT-JIS", :option => '-s' },
      2 => { :label => "EUC", :option => '-e' },
      3 => { :label => "JIS", :option => '-j' }
  }
  NEWLINE_CHARACTERS = {
      0 => { :label => "CR", :code => "\r" },
      1 => { :label => "LF", :code => "\n" },
      2 => { :label => "CR+LF", :code => "\r\n" }
  }

  # validates
  validates_presence_of :name, :url_file_name, :sql, :field_items
  validates_uniqueness_of :url_file_name
  validate :valid_file_type, :valid_encode, :valid_newline_character, :valid_sql_dangerous_word

  validates_format_of :url_file_name, :with => /^[a-zA-Z0-9_]+$/, :message => "に使用できるのは英数字と'_'です"

  validates_length_of :name, :maximum => 200
  validates_length_of :url_file_name, :maximum => 30

  def valid_sql_dangerous_word
    if /(\s|\A)(ALTER|CREATE|DROP|DELETE|ANALYZE|COMMIT|COPY)(\s|\Z)/i =~ sql
      errors.add :sql, "に'ALTER','CREATE','DROP','DELETE','ANALYZE','COMMIT','COPY' は使用しないで下さい。"
    end
  end

  def valid_file_type
    unless FILE_TYPES.key?(file_type)
      errors.add :file_type, "が範囲外の値を指定しています"
    end
  end
  def valid_encode
    unless ENCODE_TYPES.key?(encode)
      errors.add :encode, "が範囲外の値を指定しています"
    end
  end
  def valid_newline_character
    unless NEWLINE_CHARACTERS.key?(newline_character) 
      errors.add :newline_character, "が範囲外の値を指定します"
    end
  end

  # モデル　メソッド　管理画面用
  
  def self.select_enable
    ENABLE_TYPES.collect{ |value, key| [key,value] }
  end

  def self.select_file_type
    FILE_TYPES.collect{ |value, element| [element[:label],value] }
  end
  def self.select_encode
    ENCODE_TYPES.collect{ |value, element| [element[:label],value] }
  end
  def self.select_newline_character
    NEWLINE_CHARACTERS.collect{ |value, element| [element[:label],value] }
  end

  # ファイル名を生成生成
  def get_filename
    return url_file_name+'.'+FILE_TYPES[file_type][:label]
  end
  # ファイル拡張子を取得
  def get_file_type_string
    return FILE_TYPES[file_type][:label]
  end
  # ファイル出力
  def file_generate
    begin
      lists = ActiveRecord::Base.connection.execute(sql)
      return nil if lists.nil?
      logger.debug lists.class
      # ファイル形式によって異なる処理
      # CSV - TSV
      return csv_tsv_generate(lists)
    rescue
      return nil
    end
  end

private
  # CSV,TSVの出力を行う
  def csv_tsv_generate(lists)
    f = StringIO.new('','w')
    CSV::Writer.generate(f, FILE_TYPES[file_type][:delimiter], NEWLINE_CHARACTERS[newline_character][:code]) do | writer |
      # カラム名を挿入
      writer << field_items.split(",")
      field_array = field_items.split(",")
      lists.each do | items |
        if items.respond_to?('values')
          write_array = []
          field_array.each do |key|
            write_array << items[key]
          end
          writer << write_array
        else
          writer << items
        end
      end
      return NKF.nkf(ENCODE_TYPES[encode][:option] ,f.string)
    end
  end

end
