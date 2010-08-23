# -*- coding: utf-8 -*-
class AdminUser < ActiveRecord::Base

  acts_as_paranoid
  acts_as_list

  belongs_to :authority
  belongs_to :retailer
  
  def self.validates_uniqueness_of(*attr_names)
    configuration = { :message => I18n.translate("activerecord.errors.messages")[:taken], :case_sensitive => true }
    
    configuration.update(attr_names.extract_options!)

    validates_each(attr_names,configuration) do |record, attr_name, value|
      class_hierarchy = [record.class]
      while class_hierarchy.first != self
        class_hierarchy.insert(0, class_hierarchy.first.superclass)
      end

      finder_class = class_hierarchy.detect { |klass| !klass.abstract_class? }

      if value.nil? || (configuration[:case_sensitive] || !finder_class.columns_hash[attr_name.to_s].text?)
        condition_sql = attribute_condition("#{record.class.quoted_table_name}.#{attr_name}", value)
        condition_params = [value]
      else
        condition_sql = attribute_condition("LOWER(#{record.class.quoted_table_name}.#{attr_name})", value)
        condition_params = [value.downcase]
      end

      if scope = configuration[:scope]
        Array(scope).map do |scope_item|
          scope_value = record.send(scope_item)
          condition_sql << attribute_condition(" AND #{record.class.quoted_table_name}.#{scope_item}", scope_value)
          condition_params << scope_value
        end
      end

      unless record.new_record?
        condition_sql << " AND #{record.class.quoted_table_name}.#{record.class.primary_key} <> ?"
        condition_params << record.send(:id)
      end
      
      condition_sql << " AND (deleted_at IS NULL OR deleted_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}')"
      results = finder_class.with_exclusive_scope do
        connection.select_all(
          construct_finder_sql(
            :select     => "#{connection.quote_column_name(attr_name)}",
            :from       => "#{finder_class.quoted_table_name}",
            :conditions => [condition_sql, *condition_params]
          )
        )
      end

      unless results.length.zero?
        found = true

        if configuration[:case_sensitive] && finder_class.columns_hash[attr_name.to_s].text?
          found = results.any? { |a| a[attr_name.to_s] == value }
        end

        record.errors.add(attr_name, configuration[:message]) if found
      end
    end
  end


  validates_presence_of :name
  
  validates_presence_of :authority
  
  validates_presence_of :login_id

  validates_presence_of :retailer
  validates_length_of :login_id, :maximum => 15
  validates_format_of :login_id, :with => /^[a-zA-Z0-9]*$/
  validates_uniqueness_of :login_id

  validates_length_of :password, :maximum => 15, :allow_nil => true
  validates_format_of :password, :with => /^[a-zA-Z0-9]*$/

  before_create :crypt_password
  before_create :activity_true
  before_update :crypt_unless_empty


  def self.encode_password(pass)
    #passwordの文字数制限は15文字までなので、暗号化も15文字までとする
    Digest::SHA1.hexdigest("change-me--#{pass}--")[0..14]
  end

  def self.find_by_login_id_and_password login_id, password
    find(:first, :conditions => [
      'login_id=? and password=? and activity=?',
      login_id, encode_password(password), 1
    ])
  end
  
  def model_name
    'AdminUser'
  end

  def self.get_csv_settings
    columns = ['id', 'login_id']
    titles = ['id', 'login_id']
    [columns, titles]
  end

  #
  # 管理者ユーザの販売元がマスターショップであるかどうかを判定する
  #
  def master_shop?
    return true if retailer_id == Retailer::DEFAULT_ID
    return false
  end

  protected

  def crypt_password
    write_attribute "password", self.class.encode_password(password)
  end

  def crypt_unless_empty
    user = self.class.find_by_id(self.id)
    if self.password.blank?
      self.password = user.password
    elsif user.password != self.password
      write_attribute "password", self.class.encode_password(password)
    end
  end
  
  def activity_true
    self.activity = true
  end

end
