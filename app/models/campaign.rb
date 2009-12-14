# -*- coding: utf-8 -*-
class Campaign < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :product
  has_and_belongs_to_many :customers

  validates_presence_of :name, :message => "を記入してください"
  validates_presence_of :dir_name, :message => "を記入してください(半角英数字または記号)"
  validates_presence_of :opened_at
  validates_presence_of :closed_at

  validates_length_of :name, :maximum=>30, :message => "は30文字以内で入力してください"
  validates_length_of :dir_name, :maximum=>30, :message => "は30文字以内で入力してください"

  validates_format_of :dir_name, :with=>/^[\x20-\x7e]*$/, :message=>'は半角英数字または記号で入力してください'
  validates_format_of :product_id, :with => /^[0-9]*$/, :message=>'は半角数字で入力してください'

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

      condition_sql << " AND (deleted_at IS NULL OR deleted_at > '#{Time.now.gmtime.strftime("%Y-%m-%d %H:%M:%S")}')"
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

  validates_uniqueness_of :dir_name, :message=>'は重複しています'
  validates_uniqueness_of :product_id, :allow_nil => true

  def validate
    if !self.product_id.blank? && !Product.find(:first, :conditions=>["id=?", self.product_id])
      errors.add_to_base "指定されたIDを持つ商品がありません"
    end

    if !self.closed_at.blank? && !self.opened_at.blank? && (self.closed_at < self.opened_at)
      errors.add_to_base "公開終了日時が公開開始日時より前です"
    end
  end

  def available?(day=DateTime.now)
    check_term(day) && check_max_application_number
  end

  #公開期間中かをチェック
  def check_term(day=DateTime.now)
    day >= opened_at && day <= closed_at
  end

  #申込人数をオーバーしているかをチェック
  def check_max_application_number
    count = application_count.to_i
    max = max_application_number.to_i
    if count == 0 && max == 0
      return true
    elsif max == 0
      return true
    end

    count < max
  end

  #重複申込に引っかかっているかをチェック
  def duplicated?(customer)
    if repeat_application
      if customers.find(:first, :conditions => ["customers.id=?", customer.id])
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.csv(campaign)
    result = ""
    header = ["顧客ID",
              "名前１",
              "名前２",
              "フリガナ１",
              "フリガナ２",
              "郵便番号１",
              "郵便番号２",
              "都道府県",
              "住所１",
              "住所２",
              "E-MAIL",
              "電話番号１",
              "電話番号２",
              "電話番号３",
              "FAX番号１",
              "FAX番号２",
              "FAX番号３",
              "性別",
              "職業"]

    result += header.map.join(",") + "\r\n"

    questionnaires = campaign.customers

    unless questionnaires
      flash.now[:notice] = "ダウンロードデータがありません"
      redirect_to :action => :index
    end

    questionnaires.each do |c|
      arr = [
        c.id,
        c.family_name,
        c.first_name,
        c.family_name_kana,
        c.first_name_kana,
        c.zipcode01,
        c.zipcode02,
        c.prefecture.name,
        c.address_city,
        c.address_detail,
        c.email,
        c.tel01,
        c.tel02,
        c.tel03,
        c.fax01,
        c.fax02,
        c.fax03,
        System::SEX_NAMES[c.sex],
        (c.occupation.blank? ? nil : c.occupation.name)
      ]
      result << arr.join(",") << "\r\n"
    end
    result
  end

end


