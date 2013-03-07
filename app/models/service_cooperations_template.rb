# -*- coding: utf-8 -*-
class ServiceCooperationsTemplate < ActiveRecord::Base
  # validates
  validates_presence_of :template_name,:file_type,:encode,:newline_character

  validates_length_of :template_name, :service_name, :maximum => 200, :allow_nil => true
  validates_length_of :url_file_name, :maximum => 30, :allow_nil => true
  validates_length_of :description, :maximum => 9999, :allow_nil => true
  validates_format_of :url_file_name, :with => /^[a-zA-Z0-9_]*$/, :message => "に使用できるのは英数字と'_'になります", :allow_nil => true

  validate :valid_file_type, :valid_encode, :valid_newline_character, :valid_sql_dangerous_word

  def valid_sql_dangerous_word
    if /(\s|\A)(ALTER|CREATE|DROP|DELETE|ANALYZE|COMMIT|COPY)(\s|\Z)/i =~ sql
      errors.add :sql, "に'ALTER','CREATE','DROP','DELETE','ANALYZE','COMMIT','COPY' は使用しないで下さい。"
    end
  end

  def valid_file_type
    unless ServiceCooperation::FILE_TYPES.key?(file_type)
      errors.add :file_type, "が範囲外の値を指定しています"
    end
  end
  def valid_encode
    unless ServiceCooperation::ENCODE_TYPES.key?(encode)
      errors.add :encode, "が範囲外の値を指定しています"
    end
  end
  def valid_newline_character
    unless ServiceCooperation::NEWLINE_CHARACTERS.key?(newline_character)
      errors.add :newline_character, "が範囲外の値を指定しています"
    end
  end

  # 管理画面用に自分のリストを返す
  def self.select_service_cooperations_templates
    ServiceCooperationsTemplate.find(:all, :order=>"id").map{
      |rec| [ rec.template_name, rec.id.to_s]
    }
  end

end
